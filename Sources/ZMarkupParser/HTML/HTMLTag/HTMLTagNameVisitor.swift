//
//  HTMLTagNameVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

public protocol HTMLTagNameVisitor {
    associatedtype Result
        
    func visit(tagName: HTMLTagName) -> Result
    func visit(_ tagName: ExtendTagName) -> Result
    
    func visit(_ tagName: A_HTMLTagName) -> Result
    func visit(_ tagName: B_HTMLTagName) -> Result
    func visit(_ tagName: BR_HTMLTagName) -> Result
    func visit(_ tagName: DIV_HTMLTagName) -> Result
    func visit(_ tagName: HR_HTMLTagName) -> Result
    func visit(_ tagName: I_HTMLTagName) -> Result
    func visit(_ tagName: LI_HTMLTagName) -> Result
    func visit(_ tagName: OL_HTMLTagName) -> Result
    func visit(_ tagName: P_HTMLTagName) -> Result
    func visit(_ tagName: SPAN_HTMLTagName) -> Result
    func visit(_ tagName: STRONG_HTMLTagName) -> Result
    func visit(_ tagName: U_HTMLTagName) -> Result
    func visit(_ tagName: UL_HTMLTagName) -> Result
    func visit(_ tagName: DEL_HTMLTagName) -> Result
    func visit(_ tagName: TR_HTMLTagName) -> Result
    func visit(_ tagName: TD_HTMLTagName) -> Result
    func visit(_ tagName: TH_HTMLTagName) -> Result
    func visit(_ tagName: IMG_HTMLTagName) -> Result
    func visit(_ tagName: TABLE_HTMLTagName) -> Result
    func visit(_ tagName: S_HTMLTagName) -> Result
    func visit(_ tagName: PRE_HTMLTagName) -> Result
    func visit(_ tagName: BLOCKQUOTE_HTMLTagName) -> Result
    func visit(_ tagName: CODE_HTMLTagName) -> Result
    func visit(_ tagName: EM_HTMLTagName) -> Result
    func visit(_ tagName: FONT_HTMLTagName) -> Result
    
    func visit(_ tagName: H1_HTMLTagName) -> Result
    func visit(_ tagName: H2_HTMLTagName) -> Result
    func visit(_ tagName: H3_HTMLTagName) -> Result
    func visit(_ tagName: H4_HTMLTagName) -> Result
    func visit(_ tagName: H5_HTMLTagName) -> Result
    func visit(_ tagName: H6_HTMLTagName) -> Result
}

public extension HTMLTagNameVisitor {
    func visit(tagName: HTMLTagName) -> Result {
        return tagName.accept(self)
    }
}

public extension ZHTMLParserBuilder {
    static var htmlTagNames: [(HTMLTagName, MarkupStyle?)] {
        return [
            (A_HTMLTagName(), nil),
            (B_HTMLTagName(), nil),
            (BR_HTMLTagName(), nil),
            (DIV_HTMLTagName(), nil),
            (HR_HTMLTagName(), nil),
            (I_HTMLTagName(), nil),
            (LI_HTMLTagName(), nil),
            (OL_HTMLTagName(), MarkupStyle(paragraphStyle: MarkupStyleParagraphStyle(textListStyleType: .decimal))),
            (P_HTMLTagName(), nil),
            (SPAN_HTMLTagName(), nil),
            (STRONG_HTMLTagName(), nil),
            (U_HTMLTagName(), nil),
            (UL_HTMLTagName(), MarkupStyle(paragraphStyle: MarkupStyleParagraphStyle(textListStyleType: .circle))),
            (DEL_HTMLTagName(), nil),
            (TR_HTMLTagName(), nil),
            (TD_HTMLTagName(), nil),
            (TH_HTMLTagName(), nil),
            (TABLE_HTMLTagName(), nil),
            (FONT_HTMLTagName(), nil),
            (H1_HTMLTagName(), nil),
            (H2_HTMLTagName(), nil),
            (H3_HTMLTagName(), nil),
            (H4_HTMLTagName(), nil),
            (H5_HTMLTagName(), nil),
            (H6_HTMLTagName(), nil),
            (S_HTMLTagName(), nil),
            (PRE_HTMLTagName(), nil),
            (CODE_HTMLTagName(), nil),
            (EM_HTMLTagName(), nil),
            (BLOCKQUOTE_HTMLTagName(), nil),
            (IMG_HTMLTagName(handler: nil), nil),
        ]
    }
}
