//
//  FontWeightHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct FontWeightHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "font-weight"
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
