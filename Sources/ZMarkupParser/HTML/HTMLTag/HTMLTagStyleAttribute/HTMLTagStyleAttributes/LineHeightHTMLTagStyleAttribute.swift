//
//  LineHeightHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct LineHeightHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "line-height"
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
