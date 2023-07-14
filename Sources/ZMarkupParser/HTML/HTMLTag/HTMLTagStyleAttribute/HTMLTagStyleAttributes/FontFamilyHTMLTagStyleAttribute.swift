//
//  File.swift
//  
//
//  Created by 오준현 on 2023/07/14.
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
