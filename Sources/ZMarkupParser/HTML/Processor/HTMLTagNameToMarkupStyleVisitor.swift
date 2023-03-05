//
//  HTMLTagNameToMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

struct HTMLTagNameToMarkupStyleVisitor: HTMLTagNameVisitor {
    typealias Result = MarkupStyle?
    
    let customStyle: MarkupStyle?
    let attributes: [String : String]?
    let styleAttributes: [HTMLTagStyleAttribute]
    init(customStyle: MarkupStyle?, attributes: [String: String]?, styleAttributes: [HTMLTagStyleAttribute]) {
        self.customStyle = customStyle
        self.attributes = attributes
        self.styleAttributes = styleAttributes
    }
    
    func visit(_ tagName: A_HTMLTagName) -> Result {
        let linkStyle = customStyle ?? MarkupStyle.link
        guard let urlString = attributes?["href"] as? String,
              let url = URL(string: urlString) else {
            return defaultVisit(linkStyle)
        }
        var markupStyle = defaultVisit(linkStyle) ?? linkStyle
        markupStyle.link = url
        return markupStyle
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Result {
        return defaultVisit(customStyle ?? MarkupStyle.bold)
    }
    
    func visit(_ tagName: ExtendTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Result {
        return defaultVisit(customStyle ?? MarkupStyle.italic)
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Result {
        return defaultVisit(customStyle ?? MarkupStyle.bold)
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Result {
        return defaultVisit(customStyle ?? MarkupStyle.underline)
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Result {
        return defaultVisit(customStyle ?? MarkupStyle.deleteline)
    }
    
    func visit(_ tagName: IMG_HTMLTagName) -> Result {
        return defaultVisit(customStyle)
    }
}

extension HTMLTagNameToMarkupStyleVisitor {
    func defaultVisit(_ fromStyle: MarkupStyle?) -> MarkupStyle? {
        guard let styleString = self.attributes?["style"], styleAttributes.count > 0 else {
            return fromStyle
        }
        
        var markupStyle: MarkupStyle? = fromStyle
        
        let styles = styleString.split(separator: ";").filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }.map { $0.split(separator: ":") }
        
        for style in styles {
            guard style.count == 2 else {
                continue
            }
            
            let key = style[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = style[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let styleAttribute = styleAttributes.first(where: { $0.isEqualTo(styleName: key) }) {
                let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(fromStyle: markupStyle ?? MarkupStyle(), value: value)
                markupStyle = visitor.visit(styleAttribute: styleAttribute)
            }
        }
        return markupStyle
    }
}
