//
//  WordSpacingHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct WordSpacingHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "word-spacing"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
