//
//  ListStyleTypeHTMLTagStyleAttribute.swift
//
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct ListStyleTypeHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String = "list-style-type"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
