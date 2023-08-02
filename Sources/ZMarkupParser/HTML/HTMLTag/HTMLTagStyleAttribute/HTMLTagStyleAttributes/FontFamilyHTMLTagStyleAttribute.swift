//
//  FontFamilyHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/8/2.
//

import Foundation

public struct FontFamilyHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "font-family"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}

