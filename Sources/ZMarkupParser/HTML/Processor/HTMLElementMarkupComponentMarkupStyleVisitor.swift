//
//  HTMLElementMarkupComponentMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum MarkupStylePolicy {
    case respectMarkupStyleFromCode
    case respectMarkupStyleFromHTMLStyleAttribute
}

struct HTMLElementMarkupComponentMarkupStyleVisitor: MarkupVisitor {

    typealias Result = MarkupStyle?
    
    let policy: MarkupStylePolicy
    let components: [HTMLElementMarkupComponent]
    let styleAttributes: [HTMLTagStyleAttribute]
    let rootStyle: MarkupStyle?
    
    func visit(_ markup: RootMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: RawStringMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: ExtendMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: BoldMarkup) -> Result {
        return defaultVisit(components.value(markup: markup), defaultStyle: .bold)
    }
    
    func visit(_ markup: HorizontalLineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: InlineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: ColorMarkup) -> Result {
        return defaultVisit(components.value(markup: markup), defaultStyle: MarkupStyle(foregroundColor: markup.color))
    }
    
    func visit(_ markup: ItalicMarkup) -> Result {
        return defaultVisit(components.value(markup: markup), defaultStyle: .italic)
    }
    
    func visit(_ markup: LinkMarkup) -> Result {
        var markupStyle = defaultVisit(components.value(markup: markup), defaultStyle: .link) ?? .link
        if let href = components.value(markup: markup)?.attributes?["href"] as? String,
           let url = URL(string: href) {
            markupStyle.link = url
        }
        return markupStyle
    }
    
    func visit(_ markup: ListMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: ListItemMarkup) -> Result {
        var defaultStyle = defaultVisit(components.value(markup: markup)) ?? MarkupStyle()
        
        var currentMarkup: Markup? = markup.parentMarkup
        var parentListMarkup: ListMarkup?
        var parentIndent: CGFloat?
        var listStyleType: MarkupStyleType = .disc
        while let thisMarkup = currentMarkup {
            if parentListMarkup == nil, let listMarkup = thisMarkup as? ListMarkup {
                // my parent
                parentListMarkup = listMarkup
                listStyleType = visit(listMarkup)?.paragraphStyle.textListStyleType ?? .disc
            } else if parentIndent == nil, let listItemMarkup = thisMarkup as? ListItemMarkup {
                // my grand list item e.g. <ol><li>Grand<ol><li>You</li></ol></li></ol>
                parentIndent = visit(markup: listItemMarkup)?.paragraphStyle.headIndent ?? 0
            }
            currentMarkup = currentMarkup?.parentMarkup
        }
        
        guard let parentListMarkup = parentListMarkup else {
            return defaultStyle
        }
        
        
        let item: String
        if listStyleType.isOrder() {
            let siblingListItems = parentListMarkup.childMarkups.filter({ $0 is ListItemMarkup })
            let position = (siblingListItems.firstIndex(where: { $0 === markup }) ?? 0) + parentListMarkup.startingItemNumber
            item = listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: position)
        } else {
            item = listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: parentListMarkup.startingItemNumber)
        }
        
        let headIndent: CGFloat
        if let parentIndent = parentIndent, parentIndent > 0 {
            headIndent = parentIndent
        } else {
            headIndent = defaultStyle.paragraphStyle.textListHeadIndent ?? 4
        }
        
        let indent = defaultStyle.paragraphStyle.textListIndent ?? 8
        
        let inheritStyle = collectMarkupStyle(markup, defaultStyle: defaultStyle) ?? defaultStyle
        let itemWidth: CGFloat
        if inheritStyle.font.size != nil {
            itemWidth = inheritStyle.font.sizeOf(string: item)?.width ?? 4
        } else {
            itemWidth = MarkupStyle.default.font.sizeOf(string: item)?.width ?? 4
        }
        
        var tabStops: [NSTextTab] = [.init(textAlignment: .left, location: headIndent)]
        tabStops.append(.init(textAlignment: .left, location: headIndent + itemWidth + indent))
        
        defaultStyle.paragraphStyle.tabStops = defaultStyle.paragraphStyle.tabStops ?? tabStops
        defaultStyle.paragraphStyle.headIndent = defaultStyle.paragraphStyle.headIndent ?? defaultStyle.paragraphStyle.tabStops?.last?.location
        
        return defaultStyle
    }
    
    func visit(_ markup: ParagraphMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: UnderlineMarkup) -> Result {
        let htmlElement = components.value(markup: markup)
        return defaultVisit(htmlElement, defaultStyle: .underline)
    }
    
    func visit(_ markup: DeletelineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup), defaultStyle: .deleteline)
    }
    
    func visit(_ markup: TableMarkup) -> MarkupStyle? {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: TableRowMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: HeadMarkup) -> Result {
        let defaultStyle: MarkupStyle?
        switch markup.level {
        case .h1:
            defaultStyle = .h1
        case .h2:
            defaultStyle = .h2
        case .h3:
            defaultStyle = .h3
        case .h4:
            defaultStyle = .h4
        case .h5:
            defaultStyle = .h5
        case .h6:
            defaultStyle = .h6
        }
        return defaultVisit(components.value(markup: markup), defaultStyle: defaultStyle)
    }
    
    func visit(_ markup: TableColumnMarkup) -> Result {
        let htmlElement = components.value(markup: markup)
        if markup.isHeader {
            return defaultVisit(htmlElement, defaultStyle: .bold)
        } else {
            return defaultVisit(htmlElement)
        }
    }
    
    func visit(_ markup: ImageMarkup) -> MarkupStyle? {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: BlockQuoteMarkup) -> MarkupStyle? {
        return  defaultVisit(components.value(markup: markup), defaultStyle: .blockQuote)
    }
    
    func visit(_ markup: CodeMarkup) -> MarkupStyle? {
        return defaultVisit(components.value(markup: markup), defaultStyle: .code)
    }
}

extension HTMLElementMarkupComponentMarkupStyleVisitor {
    private func customStyle(_ htmlElement: HTMLElementMarkupComponent.HTMLElement?) -> MarkupStyle? {
        guard let customStyle = htmlElement?.tag.customStyle else {
            return nil
        }
        return customStyle
    }
    
    private func collectMarkupStyle(_ markup: Markup, defaultStyle: MarkupStyle? = nil) -> MarkupStyle? {
        // collect from upstream
        // String("Test") -> Bold -> Italic -> Root
        // Result: style: Bold+Italic
        
        var currentMarkup: Markup? = markup.parentMarkup
        var currentStyle = defaultStyle
        while let thisMarkup = currentMarkup {
            guard let thisMarkupStyle = visit(markup: thisMarkup) else {
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
    
    func defaultVisit(_ htmlElement: HTMLElementMarkupComponent.HTMLElement?, defaultStyle: MarkupStyle? = nil) -> Result {
        
        var markupStyle: MarkupStyle? = nil
        if let customStyle = customStyle(htmlElement) {
            // has custom style
            markupStyle = customStyle
        }
        
        if let styleString = htmlElement?.attributes?["style"],
              styleAttributes.count > 0 {
            let styles = styleString.split(separator: ";").filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }.map { $0.split(separator: ":") }
            
            for style in styles {
                guard style.count == 2 else {
                    continue
                }
                
                let key = style[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = style[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let styleAttribute = styleAttributes.first(where: { $0.isEqualTo(styleName: key) }) {
                    let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: value)
                    if var thisMarkupStyle = visitor.visit(styleAttribute: styleAttribute) {
                        switch policy {
                        case .respectMarkupStyleFromCode:
                            if var markupStyle = markupStyle {
                                markupStyle.fillIfNil(from: thisMarkupStyle)
                            } else {
                                markupStyle = thisMarkupStyle
                            }
                        case .respectMarkupStyleFromHTMLStyleAttribute:
                            thisMarkupStyle.fillIfNil(from: markupStyle ?? defaultStyle)
                            markupStyle = thisMarkupStyle
                        }
                    }
                }
            }
        }
        
        return markupStyle ?? defaultStyle
    }
}
