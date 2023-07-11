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
    static var htmlTagNames: [HTMLTagName] {
        return [
            A_HTMLTagName(),
            B_HTMLTagName(),
            BR_HTMLTagName(),
            DIV_HTMLTagName(),
            HR_HTMLTagName(),
            I_HTMLTagName(),
            LI_HTMLTagName(),
            OL_HTMLTagName(),
            P_HTMLTagName(),
            SPAN_HTMLTagName(),
            STRONG_HTMLTagName(),
            U_HTMLTagName(),
            UL_HTMLTagName(),
            DEL_HTMLTagName(),
            TR_HTMLTagName(),
            TD_HTMLTagName(),
            TH_HTMLTagName(),
            TABLE_HTMLTagName(),
            FONT_HTMLTagName(),
            H1_HTMLTagName(),
            H2_HTMLTagName(),
            H3_HTMLTagName(),
            H4_HTMLTagName(),
            H5_HTMLTagName(),
            H6_HTMLTagName(),
            S_HTMLTagName(),
            PRE_HTMLTagName(),
            CODE_HTMLTagName(),
            EM_HTMLTagName(),
            BLOCKQUOTE_HTMLTagName(),
            IMG_HTMLTagName(handler: nil)
        ]
    }
}
