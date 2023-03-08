//
//  HTMLTagNameToMarkupVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

struct HTMLTagNameToMarkupVisitor: HTMLTagNameVisitor {
    typealias Result = Markup
    
    func visit(_ tagName: A_HTMLTagName) -> Result {
        return LinkMarkup()
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Result {
        return BoldMarkup()
    }
    
    func visit(_ tagName: ExtendTagName) -> Result {
        return ExtendMarkup()
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Result {
        return BreakLineMarkup()
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Result {
        return ParagraphMarkup()
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Result {
        return HorizontalLineMarkup(dashLength: tagName.dashLength)
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Result {
        return ItalicMarkup()
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Result {
        return ListItemMarkup()
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Result {
        return ListMarkup(styleList: tagName.listStyle)
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Result {
        return ParagraphMarkup()
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Result {
        return InlineMarkup()
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Result {
        return BoldMarkup()
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Result {
        return UnderlineMarkup()
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Result {
        return ListMarkup(styleList: tagName.listStyle)
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Result {
        return DeletelineMarkup()
    }
    
    func visit(_ tagName: TR_HTMLTagName) -> Result {
        return TableRowMarkup()
    }
    
    func visit(_ tagName: TD_HTMLTagName) -> Result {
        return TableColumnMarkup(isHeader: false, fixedMaxLength: tagName.fixedMaxLength)
    }
    
    func visit(_ tagName: TH_HTMLTagName) -> Result {
        return TableColumnMarkup(isHeader: true, fixedMaxLength: tagName.fixedMaxLength)
    }
}
