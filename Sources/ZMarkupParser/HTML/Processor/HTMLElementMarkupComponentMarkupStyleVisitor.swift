//
//  HTMLElementMarkupComponentMarkupStyleVisitor.swift
//  
//
//  Created by Harry Li on 2023/3/8.
//

import Foundation

struct HTMLElementMarkupComponentMarkupStyleVisitor: MarkupVisitor {

    typealias Result = MarkupStyle?
    
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
        return defaultVisit(components.value(markup: markup)) ?? .bold
    }
    
    func visit(_ markup: HorizontalLineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: InlineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: ItalicMarkup) -> Result {
        return defaultVisit(components.value(markup: markup)) ?? .italic
    }
    
    func visit(_ markup: LinkMarkup) -> Result {
        var markupStyle = defaultVisit(components.value(markup: markup)) ?? .link
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
        return defaultVisit(components.value(markup: markup)) ?? .underline
    }
    
    func visit(_ markup: DeletelineMarkup) -> Result {
        return defaultVisit(components.value(markup: markup)) ?? .deleteline
    }
    
    func visit(_ markup: TableMarkup) -> MarkupStyle? {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: TableRowMarkup) -> Result {
        return defaultVisit(components.value(markup: markup))
    }
    
    func visit(_ markup: TableColumnMarkup) -> Result {
        if markup.isHeader {
            return defaultVisit(components.value(markup: markup)) ?? .bold
        } else {
            return defaultVisit(components.value(markup: markup))
        }
    }
    
    func visit(_ markup: ImageMarkup) -> MarkupStyle? {
        return defaultVisit(components.value(markup: markup))
    }
}

extension HTMLElementMarkupComponentMarkupStyleVisitor {
    func defaultVisit(_ htmlElement: HTMLElementMarkupComponent.HTMLElement?) -> Result {
        var markupStyle: MarkupStyle?
        guard let styleString = htmlElement?.attributes?["style"],
              styleAttributes.count > 0 else {
            if var customStyle = htmlElement?.tag.customStyle {
                customStyle.fillIfNil(from: markupStyle)
                markupStyle = customStyle
            }
            return markupStyle
        }
        
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
                    thisMarkupStyle.fillIfNil(from: markupStyle)
                    markupStyle = thisMarkupStyle
                }
            }
        }
        
        if var customStyle = htmlElement?.tag.customStyle {
            customStyle.fillIfNil(from: markupStyle)
            markupStyle = customStyle
        }
        
        return markupStyle
    }
}
