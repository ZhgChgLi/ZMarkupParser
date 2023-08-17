//
//  HTMLElementMarkupComponentMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation

public enum MarkupStylePolicy {
    case respectMarkupStyleFromCode
    case respectMarkupStyleFromHTMLStyleAttribute
}

struct HTMLElementMarkupComponentMarkupStyleVisitor: MarkupVisitor {

    typealias Result = MarkupStyle?
    
    let policy: MarkupStylePolicy
    let components: [HTMLElementMarkupComponent]
    let styleAttributes: [HTMLTagStyleAttribute]
    
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
    
    func visit(_ markup: ListItemMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: ListMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
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
