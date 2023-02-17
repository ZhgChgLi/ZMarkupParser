//
//  ColorHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/1.
//

import Foundation

public struct ColorHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "color"
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
