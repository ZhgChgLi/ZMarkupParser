//
//  HTMLTagNameToMarkupVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

struct HTMLTagNameToMarkupVisitor: HTMLTagNameVisitor {
    typealias Result = Markup
    
    let tagAttributedString: NSAttributedString
    let attributes: [String : String]?
    let style: MarkupStyle?
    init(tagAttributedString: NSAttributedString, attributes: [String: String]?, with style: MarkupStyle?) {
        self.tagAttributedString = tagAttributedString
        self.attributes = attributes
        self.style = style
    }
    
    func visit(_ tagName: A_HTMLTagName) -> Result {
        return LinkMarkup(style: style)
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Result {
        return BoldMarkup(style: style)
    }
    
    func visit(_ tagName: ExtendTagName) -> Result {
        return ExtendMarkup(style: style)
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Result {
        return BreakLineMarkup(style: style)
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Result {
        return ParagraphMarkup(style: style)
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Result {
        return HorizontalLineMarkup(style: style)
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Result {
        return ItalicMarkup(style: style)
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Result {
        return ListItemMarkup(style: style)
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Result {
        return OrderListMarkup(style: style)
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Result {
        return ParagraphMarkup(style: style)
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Result {
        return InlineMarkup(style: style)
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Result {
        return BoldMarkup(style: style)
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Result {
        return UnderlineMarkup(style: style)
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Result {
        return UnorderListMarkup(style: style)
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Result {
        return DeletelineMarkup(style: style)
    }
}
