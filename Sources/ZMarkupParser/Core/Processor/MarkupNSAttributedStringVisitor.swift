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
    
    static let breakLineSymbol = "\n"
    
    func visit(_ markup: RootMarkup) -> Result {
        return reduceBreaklineInResultNSAttributedString(collectAttributedString(markup))
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        return makeString(in: markup, string: Self.breakLineSymbol, attributes: [.breaklinePlaceholder: NSAttributedString.Key.BreaklinePlaceholder.breaklineTag])
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
        let thisAttributedString = NSMutableAttributedString(attributedString: makeString(in: markup, string: String(repeating: "-", count: markup.dashLength)))
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
        
        // We don't set NSTextList to NSParagraphStyle directly, because NSTextList have abnormal extra spaces.
        // ref: https://stackoverflow.com/questions/66714650/nstextlist-formatting
        
        var level = 0
        var parentMarkup: Markup? = markup.parentMarkup as? ListMarkup
        while (parentMarkup != nil) {
            if parentMarkup is ListMarkup {
                level += 1
            }
            parentMarkup = parentMarkup?.parentMarkup
        }
        
        if let parentMarkup = markup.parentMarkup as? ListMarkup {
            let indent = String(repeating: parentMarkup.styleList.indentSymobol, count: level - 1)
            let thisAttributedString: NSMutableAttributedString
            if parentMarkup.styleList.type.isOrder() {
                let siblingListItems = markup.parentMarkup?.childMarkups.filter({ $0 is ListItemMarkup }) ?? []
                let position = (siblingListItems.firstIndex(where: { $0 === markup }) ?? 0) + parentMarkup.styleList.startingItemNumber
                thisAttributedString = NSMutableAttributedString(attributedString: makeString(in: markup, string:indent+parentMarkup.styleList.marker(forItemNumber: position)))
            } else {
                thisAttributedString = NSMutableAttributedString(attributedString: makeString(in: markup, string:indent+parentMarkup.styleList.marker(forItemNumber: parentMarkup.styleList.startingItemNumber)))
            }
            attributedString.insert(thisAttributedString, at: 0)
            attributedString.markSuffixTagBoundaryBreakline()
        }
        
        return attributedString
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
        let thisAttributedString = NSMutableAttributedString(attributedString: attributedString)
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
            attributedString.append(makeString(in: markup, string: String(repeating: " ", count: markup.spacing)))
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
        
        // merge tag Boundary Breakline, e.g. </p></div> -> /n/n -> /n
        var pre: (NSRange, NSAttributedString.Key.BreaklinePlaceholder)?
        mutableAttributedString.enumerateAttribute(.breaklinePlaceholder, in: NSMakeRange(0, totalLength)) { value, range, _ in
            if let breaklinePlaceholder = value as? NSAttributedString.Key.BreaklinePlaceholder {
                if range.location == 0 {
                    mutableAttributedString.deleteCharacters(in: range)
                } else if let pre = pre {
                    let preRange = pre.0
                    let preBreaklinePlaceholder = pre.1
                    
                    switch (preBreaklinePlaceholder, breaklinePlaceholder) {
                    case (.breaklineTag, .tagBoundarySuffix):
                        // <br/></div> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    case (.breaklineTag, .tagBoundaryPrefix):
                        // <br/><p> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    case (.tagBoundarySuffix, .tagBoundarySuffix):
                        // </div></div> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    case (.tagBoundarySuffix, .tagBoundaryPrefix):
                        // </div><p> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    case (.tagBoundaryPrefix, .tagBoundaryPrefix):
                        // <div><p> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    case (.tagBoundaryPrefix, .tagBoundarySuffix):
                        // <p></p> -> /n/n -> /n
                        mutableAttributedString.deleteCharacters(in: preRange)
                    default:
                        break
                    }
                }
                pre = (range, breaklinePlaceholder)
            } else {
                pre = nil
            }
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
    
    func makeString(in markup: Markup, string: String, attributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString {
        let attributedString: NSAttributedString
        if let attrs = attrs, !attrs.isEmpty {
            attributedString = NSAttributedString(string: string, attributes: attrs)
        } else {
            attributedString = NSAttributedString(string: string)
        }
        return applyMarkupStyle(attributedString, with: collectMarkupStyle(markup))
    }
}

private extension MarkupNSAttributedStringVisitor {
    func collectAttributedString(_ markup: Markup) -> NSMutableAttributedString {
        // collect from downstream
        // Root -> Bold -> String("Bold")
        //      \
        //       > String("Test")
        // Result: Bold Test
        
        return markup.childMarkups.compactMap({ visit(markup: $0) }).reduce(NSMutableAttributedString()) { partialResult, attributedString in
            partialResult.append(attributedString)
            return partialResult
        }
    }
    
    func collectMarkupStyle(_ markup: Markup) -> MarkupStyle? {
        // collect from upstream
        // String("Test") -> Bold -> Italic -> Root
        // Result: style: Bold+Italic
        
        var currentMarkup: Markup? = markup.parentMarkup
        var currentStyle = components.value(markup: markup)
        while let thisMarkup = currentMarkup {
            guard let thisMarkupStyle = components.value(markup: thisMarkup) else {
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

private extension NSAttributedString.Key {
    static let breaklinePlaceholder: NSAttributedString.Key = .init("breaklinePlaceholder")
    struct BreaklinePlaceholder: OptionSet {
        let rawValue: Int

        static let tagBoundaryPrefix = BreaklinePlaceholder(rawValue: 1)
        static let tagBoundarySuffix = BreaklinePlaceholder(rawValue: 2)
        static let breaklineTag = BreaklinePlaceholder(rawValue: 3)
    }
}

private extension NSMutableAttributedString {
    func markPrefixTagBoundaryBreakline() {
        self.insert(NSAttributedString(string: MarkupNSAttributedStringVisitor.breakLineSymbol, attributes: [.breaklinePlaceholder: NSAttributedString.Key.BreaklinePlaceholder.tagBoundaryPrefix]), at: 0)
    }
    
    func markSuffixTagBoundaryBreakline() {
        self.append(NSAttributedString(string: MarkupNSAttributedStringVisitor.breakLineSymbol, attributes: [.breaklinePlaceholder: NSAttributedString.Key.BreaklinePlaceholder.tagBoundarySuffix]))
    }
}
