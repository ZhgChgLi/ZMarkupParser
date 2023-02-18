//
//  BackgroundColorHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct BackgroundColorHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "background-color"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
