//
//  ExtendHTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct ExtendHTMLTagStyleAttribute: HTMLTagStyleAttribute {
    public let styleName: String
    public let style: MarkupStyle?
    
    public init(styleName: String, style: MarkupStyle?) {
        self.styleName = styleName
        self.style = style
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
        return visitor.visit(self)
    }
}
