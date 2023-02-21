//
//  MarkupNSAttributedStringVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

struct MarkupNSAttributedStringVisitor: MarkupVisitor {
    typealias Result = NSAttributedString
    
    func visit(_ markup: RootMarkup) -> Result {
        return reduceBreaklineInResultNSAttributedString(collectAttributedString(markup))
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        if markup.reduceable {
            return visit(RawStringMarkup(attributedString: NSAttributedString(string: "\n", attributes: [.reduceableBreakLine: true])))
        } else {
            return visit(RawStringMarkup(attributedString: NSAttributedString(string: "\n")))
        }
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
        markup.appendChild(markup: BreakLineMarkup())
        markup.appendChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: String(repeating: "-", count: markup.dashLength))))
        markup.prependChild(markup: BreakLineMarkup())
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: InlineMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ItalicMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: LinkMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ListItemMarkup) -> Result {
        
        let isOrder = markup.parentMarkup is OrderListMarkup
        let siblingListItems = markup.parentMarkup?.childMarkups.compactMap({ $0 as? ListItemMarkup }) ?? []
        let currentListItemIndex = siblingListItems.firstIndex(where: { $0 === markup }) ?? 0
        
        if isOrder {
            markup.prependChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "\(currentListItemIndex + 1).")))
        } else {
            markup.prependChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "•")))
        }
        
        markup.appendChild(markup: BreakLineMarkup())
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: UnorderListMarkup) -> Result {
        markup.prependChild(markup: BreakLineMarkup())
        markup.appendChild(markup: BreakLineMarkup())
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: OrderListMarkup) -> Result {
        markup.prependChild(markup: BreakLineMarkup())
        markup.appendChild(markup: BreakLineMarkup())
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: ParagraphMarkup) -> Result {
        markup.appendChild(markup: BreakLineMarkup(reduceable: false))
        markup.prependChild(markup: BreakLineMarkup(reduceable: false))
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: UnderlineMarkup) -> Result {
        return collectAttributedString(markup)
    }
    
    func visit(_ markup: DeletelineMarkup) -> NSAttributedString {
        return collectAttributedString(markup)
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
        mutableAttributedString.addAttributes(markupStyle.render(), range: NSMakeRange(0, mutableAttributedString.string.utf16.count))
        return mutableAttributedString
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
        var currentStyle = markup.style
        while let thisMarkup = currentMarkup {
            guard let thisMarkupStyle = thisMarkup.style else {
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
        
        return currentStyle
    }
}

private extension NSAttributedString.Key {
    static let reduceableBreakLine: NSAttributedString.Key = .init("reduceableBreakLine")
}
