//
//  MarkupNSAttributedStringVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

struct MarkupNSAttributedStringVisitor: MarkupVisitor {

    typealias Result = NSAttributedString

    let components: [MarkupStyleComponent]
    let rootStyle: MarkupStyle?
    /// O(1) per-markup lookup of the same data as `components`; built once on init so the visitor
    /// avoids the per-call O(N) `Array.first(where:)` scan (legacy hot loop was O(N^2)).
    let componentsLookup: [ObjectIdentifier: MarkupStyle]
    /// Precomputed top-down effective style for each markup, keyed by `ObjectIdentifier`.
    /// Allows the leaf-side `collectMarkupStyle` to avoid walking up the parent chain.
    let effectiveStyles: [ObjectIdentifier: MarkupStyle]
    /// Pre-built `ListItemMarkup` -> `(parent ListMarkup, sibling index)` table so
    /// rendering each list item is O(1) instead of O(N) per item / O(N^2) per list.
    let listLookup: ListIndexLookup

    init(
        components: [MarkupStyleComponent],
        rootStyle: MarkupStyle?,
        effectiveStyles: [ObjectIdentifier: MarkupStyle] = [:],
        listLookup: ListIndexLookup = .empty
    ) {
        self.components = components
        self.rootStyle = rootStyle
        self.componentsLookup = components.buildLookup()
        self.effectiveStyles = effectiveStyles
        self.listLookup = listLookup
    }

    static let breakLineSymbol = "\n"
    
    func visit(_ markup: RootMarkup) -> Result {
        return reduceBreaklineInResultNSAttributedString(collectAttributedString(markup))
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        let style = collectMarkupStyle(markup)
        return makeString(in: markup, string: Self.breakLineSymbol, attributes: [.breaklinePlaceholder: BreaklineTag()], style: style)
    }
    
    func visit(_ markup: RawStringMarkup) -> Result {
        return applyMarkupStyle(markup.attributedString, with: collectMarkupStyle(markup))
    }
    
    func visit(_ markup: ExtendMarkup) -> Result {
        return collectAttributedString(markup)
    }
        
    func visit(_ markup: BoldMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: HorizontalLineMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let style = collectMarkupStyle(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: makeString(in: markup, string: String(repeating: "-", count: markup.dashLength), style: style))
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        attributedString.append(thisAttributedString)
        return attributedString
    }
    
    func visit(_ markup: InlineMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ColorMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ItalicMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: LinkMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ListItemMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let style = collectMarkupStyle(markup)

        // We don't set NSTextList to NSParagraphStyle directly, because NSTextList have abnormal extra spaces.
        // ref: https://stackoverflow.com/questions/66714650/nstextlist-formatting

        // Fast path: pre-built `ListIndexLookup` gives us the parent `ListMarkup` and
        // sibling index directly. Falls back to walking the parent chain for callers
        // that built the visitor without a lookup (legacy direct instantiation).
        let parentListMarkup: ListMarkup?
        let zeroBasedPosition: Int
        if let lookedUpParent = listLookup.parentList[ObjectIdentifier(markup)] {
            parentListMarkup = lookedUpParent
            zeroBasedPosition = listLookup.positionInList[ObjectIdentifier(markup)] ?? 0
        } else {
            var found: ListMarkup?
            var currentMarkup: Markup? = markup.parentMarkup
            while let thisMarkup = currentMarkup {
                if let listMarkup = thisMarkup as? ListMarkup {
                    found = listMarkup
                    break
                }
                currentMarkup = thisMarkup.parentMarkup
            }
            parentListMarkup = found
            if let parent = found {
                let siblingListItems = parent.childMarkups.filter({ $0 is ListItemMarkup })
                zeroBasedPosition = siblingListItems.firstIndex(where: { $0 === markup }) ?? 0
            } else {
                zeroBasedPosition = 0
            }
        }

        guard let parentListMarkup = parentListMarkup else {
            return attributedString
        }

        let listStyleType: MarkupStyleType = componentsLookup.value(markup: parentListMarkup)?.paragraphStyle.textListStyleType ?? .disc

        let string: String
        if listStyleType.isOrder() {
            let position = zeroBasedPosition + parentListMarkup.startingItemNumber
            string = String(format: listStyleType.getFormat(), listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: position))
        } else {
            string = String(format: listStyleType.getFormat(), listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: parentListMarkup.startingItemNumber))
        }

        // Build `bullet + children` by appending into a fresh mutable string instead of
        // `insert(at: 0)` on the already-collected nested content. For deeply nested
        // lists the inner subtree can be many KB and `insert(at: 0)` shifts it on every
        // wrapping level — append-only avoids that O(L * depth) cost.
        let bullet = makeString(in: markup, string: string, style: style)
        let result = NSMutableAttributedString(attributedString: bullet)
        result.beginEditing()
        result.append(attributedString)
        result.endEditing()
        result.markSuffixTagBoundaryBreakline()

        return result
    }
    
    func visit(_ markup: ListMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        return thisAttributedString
    }
    
    func visit(_ markup: ParagraphMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        var thisAttributedString = NSMutableAttributedString(attributedString: attributedString)

        // This code replicates browser behavior by trimming leading and trailing whitespace around HTML tags.
        // It removes unnecessary spaces and newlines at the beginning and end of the NSAttributedString.
        // If the entire content is just whitespace, it replaces it with an empty string.

        if thisAttributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            thisAttributedString = NSMutableAttributedString(string: "")
        }
        
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        return thisAttributedString
    }
    
    func visit(_ markup: UnderlineMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: DeletelineMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: TableColumnMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let siblingColumns = markup.parentMarkup?.childMarkups.filter({ $0 is TableColumnMarkup }) ?? []
        let position = (siblingColumns.firstIndex(where: { $0 === markup }) ?? 0)
        let style = collectMarkupStyle(markup)
        
        var maxLength: Int? = markup.fixedMaxLength
        if maxLength == nil {
            if let tableRowMarkup = markup.parentMarkup as? TableRowMarkup,
               let firstTableRow = tableRowMarkup.parentMarkup?.childMarkups.first(where: { $0 is TableRowMarkup }) as? TableRowMarkup {
                let firstTableRowColumns = firstTableRow.childMarkups.filter({ $0 is TableColumnMarkup })
                if firstTableRowColumns.indices.contains(position) {
                    let firstTableRowColumnAttributedString = collectAttributedString(firstTableRowColumns[position])
                    let length = firstTableRowColumnAttributedString.string.utf16.count
                    maxLength = length
                }
            }
        }
        
        if let maxLength = maxLength {
            if attributedString.string.utf16.count > maxLength {
                attributedString.mutableString.setString(String(attributedString.string.prefix(maxLength))+"...")
            } else {
                attributedString.mutableString.setString(attributedString.string.padding(toLength: maxLength, withPad: " ", startingAt: 0))
            }
        }
        
        if position < siblingColumns.count - 1 {
            attributedString.append(makeString(in: markup, string: String(repeating: " ", count: markup.spacing), style: style))
        }
        
        return attributedString
    }
    
    func visit(_ markup: TableRowMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
        thisAttributedString.markSuffixTagBoundaryBreakline()

        return thisAttributedString
    }
    
    func visit(_ markup: TableMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        return thisAttributedString
    }
    
    func visit(_ markup: HeadMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        return thisAttributedString
    }

    func visit(_ markup: ImageMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        attributedString.insert(NSAttributedString(attachment: markup.attachment), at: 0)
        return attributedString
    }
    
    func visit(_ markup: BlockQuoteMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
        thisAttributedString.markPrefixTagBoundaryBreakline()
        thisAttributedString.markSuffixTagBoundaryBreakline()
        
        return thisAttributedString
    }
    
    func visit(_ markup: CodeMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        return attributedString
    }
}

extension MarkupNSAttributedStringVisitor {
    // Find continues reduceable breakline and merge it.
    func reduceBreaklineInResultNSAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let totalLength = mutableAttributedString.string.utf16.count
        
        var rangesToDelete: [NSRange] = []
        
        // merge tag Boundary Breakline, e.g. </p></div> -> /n/n -> /n
        var pre: (NSRange, any BreaklinePlaceholder)?
        mutableAttributedString.enumerateAttribute(.breaklinePlaceholder, in: NSMakeRange(0, totalLength)) { value, range, _ in
            if let breaklinePlaceholder = value as? any BreaklinePlaceholder {
                if range.location == 0 {
                    rangesToDelete.append(range)
                } else if let pre = pre {
                    let preRange = pre.0
                    let preBreaklinePlaceholder = pre.1
                    
                    switch (preBreaklinePlaceholder, breaklinePlaceholder) {
                    case (is BreaklineTag, is TagBoundarySuffix):
                        // <br/></div> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    case (is BreaklineTag, is TagBoundaryPrefix):
                        // <br/><p> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    case (is TagBoundarySuffix, is TagBoundarySuffix):
                        // </div></div> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    case (is TagBoundarySuffix, is TagBoundaryPrefix):
                        // </div><p> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    case (is TagBoundaryPrefix, is TagBoundaryPrefix):
                        // <div><p> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    case (is TagBoundaryPrefix, is TagBoundarySuffix):
                        // <p></p> -> /n/n -> /n
                        rangesToDelete.append(preRange)
                    default:
                        break
                    }
                }
                pre = (range, breaklinePlaceholder)
            } else {
                pre = nil
            }
        }
        
        // Delete ranges in reverse order to avoid range shifting issues
        for range in rangesToDelete.reversed() {
            mutableAttributedString.deleteCharacters(in: range)
        }
        
        return mutableAttributedString
    }
    
    func applyMarkupStyle(_ attributedString: NSAttributedString, with markupStyle: MarkupStyle?) -> NSAttributedString {
        guard let markupStyle = markupStyle else { return attributedString }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        if markupStyle.fontCase == .lowercase {
            mutableAttributedString.enumerateAttributes(in: NSRange(location: 0, length: mutableAttributedString.string.utf16.count), options: []) {_, range, _ in
                mutableAttributedString.replaceCharacters(in: range, with: (attributedString.string as NSString).substring(with: range).lowercased())
            }
        } else if markupStyle.fontCase == .uppercase {
            mutableAttributedString.enumerateAttributes(in: NSRange(location: 0, length: mutableAttributedString.string.utf16.count), options: []) {_, range, _ in
                mutableAttributedString.replaceCharacters(in: range, with: (mutableAttributedString.string as NSString).substring(with: range).uppercased())
            }
        }
        
        mutableAttributedString.addAttributes(markupStyle.render(), range: NSMakeRange(0, mutableAttributedString.string.utf16.count))
        return mutableAttributedString
    }
    
    func makeString(in markup: Markup, string: String, attributes attrs: [NSAttributedString.Key : Any]? = nil, style: MarkupStyle?) -> NSAttributedString {
        let attributedString: NSAttributedString
        if let attrs = attrs, !attrs.isEmpty {
            attributedString = NSAttributedString(string: string, attributes: attrs)
        } else {
            attributedString = NSAttributedString(string: string)
        }
        return applyMarkupStyle(attributedString, with: style)
    }
}

private extension MarkupNSAttributedStringVisitor {
    func collectAttributedString(_ markup: Markup) -> NSMutableAttributedString {
        // Walks the children once, batching mutations under begin/endEditing to skip the
        // attribute fixup work `NSMutableAttributedString` does after every `append`.
        let result = NSMutableAttributedString()
        let children = markup.childMarkups
        guard !children.isEmpty else { return result }
        result.beginEditing()
        for child in children {
            result.append(visit(markup: child))
        }
        result.endEditing()
        return result
    }
    
    func collectMarkupStyle(_ markup: Markup) -> MarkupStyle? {
        // Fast path: the precomputed top-down effective style already merged the entire
        // parent chain *plus* `rootStyle` at process() time, so this is now an O(1) dictionary
        // hit with no per-leaf `fillIfNil` work.
        if !effectiveStyles.isEmpty {
            if let cached = effectiveStyles[ObjectIdentifier(markup)] {
                return cached
            }
            return rootStyle
        }

        // Fallback (no cache available, e.g. legacy direct visitor instantiation): preserve
        // the original upstream walk so visitor-only callers still work.
        var currentMarkup: Markup? = markup.parentMarkup
        var currentStyle = componentsLookup.value(markup: markup)
        while let thisMarkup = currentMarkup {
            guard let thisMarkupStyle = componentsLookup.value(markup: thisMarkup) else {
                currentMarkup = thisMarkup.parentMarkup
                continue
            }

            if var thisCurrentStyle = currentStyle {
                thisCurrentStyle.fillIfNil(from: thisMarkupStyle)
                currentStyle = thisCurrentStyle
            } else {
                currentStyle = thisMarkupStyle
            }

            currentMarkup = thisMarkup.parentMarkup
        }

        if var currentStyle = currentStyle {
            currentStyle.fillIfNil(from: rootStyle)
            return currentStyle
        } else {
            return rootStyle
        }
    }
}

private protocol BreaklinePlaceholder: Hashable {
    
}

private class TagBoundaryPrefix: NSObject, BreaklinePlaceholder{
    
}

private class TagBoundarySuffix: NSObject, BreaklinePlaceholder{
    
}

private class BreaklineTag: NSObject, BreaklinePlaceholder{
    
}


private extension NSAttributedString.Key {
    static let breaklinePlaceholder: NSAttributedString.Key = .init("breaklinePlaceholder")
}

private extension NSMutableAttributedString {
    func markPrefixTagBoundaryBreakline() {
        self.insert(NSAttributedString(string: MarkupNSAttributedStringVisitor.breakLineSymbol, attributes: [.breaklinePlaceholder: TagBoundaryPrefix()]), at: 0)
    }
    
    func markSuffixTagBoundaryBreakline() {
        self.append(NSAttributedString(string: MarkupNSAttributedStringVisitor.breakLineSymbol, attributes: [.breaklinePlaceholder: TagBoundarySuffix()]))
    }
}
