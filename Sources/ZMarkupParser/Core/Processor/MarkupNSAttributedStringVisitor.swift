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
    
    func visit(_ markup: RootMarkup) -> Result {
        return reduceBreaklineInResultNSAttributedString(collectAttributedString(markup))
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        return makeBreakLine(in: markup)
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
        
        attributedString.append(makeBreakLine(in: markup))
        attributedString.append(makeString(in: markup, string: String(repeating: "-", count: markup.dashLength)))
        attributedString.insert(makeBreakLine(in: markup), at: 0)
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
        
        if let parentMarkup = markup.parentMarkup as? ListMarkup {
            if parentMarkup.styleList.type.isOrder() {
                let siblingListItems = markup.parentMarkup?.childMarkups.filter({ $0 is ListItemMarkup }) ?? []
                let position = (siblingListItems.firstIndex(where: { $0 === markup }) ?? 0) + parentMarkup.styleList.startingItemNumber
                attributedString.insert(makeString(in: markup, string:parentMarkup.styleList.marker(forItemNumber: position)), at: 0)
            } else {
                attributedString.insert(makeString(in: markup, string:parentMarkup.styleList.marker(forItemNumber: parentMarkup.styleList.startingItemNumber)), at: 0)
            }
            
            attributedString.append(makeBreakLine(in: markup))
        }
        
        return attributedString
    }
    
    func visit(_ markup: ListMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        attributedString.append(makeBreakLine(in: markup))
        attributedString.insert(makeBreakLine(in: markup), at: 0)
        return attributedString
    }
    
    func visit(_ markup: ParagraphMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        attributedString.append(makeBreakLine(in: markup, reduceable: false))
        attributedString.insert(makeBreakLine(in: markup, reduceable: false), at: 0)
        return attributedString
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
        attributedString.append(makeBreakLine(in: markup))
        return attributedString
    }
    
    func visit(_ markup: TableMarkup) -> Result {
        let attributedString = collectAttributedString(markup)
        attributedString.append(makeBreakLine(in: markup))
        attributedString.insert(makeBreakLine(in: markup), at: 0)
        return attributedString
    }
    
    func visit(_ markup: HeadMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        attributedString.append(makeBreakLine(in: markup))
        attributedString.insert(makeBreakLine(in: markup), at: 0)
        return attributedString
    }

    func visit(_ markup: ImageMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        attributedString.insert(NSAttributedString(attachment: markup.attachment), at: 0)
        return attributedString
    }
    
    func visit(_ markup: BlockQuoteMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        attributedString.append(makeBreakLine(in: markup))
        attributedString.insert(makeBreakLine(in: markup), at: 0)
        return attributedString
    }
    
    func visit(_ markup: CodeMarkup) -> NSAttributedString {
        let attributedString = collectAttributedString(markup)
        return attributedString
    }
}

extension MarkupNSAttributedStringVisitor {
    // Find continues reduceable breakline and merge it.
    // e.g. Test\n\n\n\nTest -> Test\nTest
    func reduceBreaklineInResultNSAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

        let totalLength = mutableAttributedString.string.utf16.count
        mutableAttributedString.enumerateAttribute(.reduceableBreakLine, in: NSMakeRange(0, totalLength)) { reduceableBreakLine, range, _ in
            if let reduceableBreakLine = reduceableBreakLine as? Bool, reduceableBreakLine == true {
                if range.location == 0 || range.upperBound == mutableAttributedString.string.utf16.count {
                    // remove prefix & suffix break line
                    mutableAttributedString.replaceCharacters(in: range, with: "")
                } else if range.length >= 2 {
                    // remove reduntant
                    mutableAttributedString.replaceCharacters(in: range, with: "\n")
                }
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
    
    func makeBreakLine(in markup: Markup, reduceable: Bool = true) -> NSAttributedString {
        if reduceable {
            return makeString(in: markup, string: "\n", attributes: [.reduceableBreakLine: true])
        } else {
            return makeString(in: markup, string: "\n")
        }
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
    static let reduceableBreakLine: NSAttributedString.Key = .init("reduceableBreakLine")
}
