//
 //  TextAlignHTMLTagStyleAttribute.swift
 //
 //
 //  Created by 오준현 on 2023/08/10.
 //
 import Foundation

 public struct TextAlignHTMLTagStyleAttribute: HTMLTagStyleAttribute {
     public let styleName: String = "text-align"

     public init() {

     }

     public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagStyleAttributeVisitor {
         return visitor.visit(self)
     }
 }
