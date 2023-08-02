//
//  HTMLTagStyleAttributeVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/1.
//

import Foundation

public protocol HTMLTagStyleAttributeVisitor {
    associatedtype Result
    
    func visit(styleAttribute: HTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: ExtendHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: ColorHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: BackgroundColorHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: FontSizeHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: FontWeightHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: FontFamilyHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: LineHeightHTMLTagStyleAttribute) -> Result
    func visit(_ styleAttribute: WordSpacingHTMLTagStyleAttribute) -> Result
}

public extension HTMLTagStyleAttributeVisitor {
    func visit(styleAttribute: HTMLTagStyleAttribute) -> Result {
        return styleAttribute.accept(self)
    }
}

public extension ZHTMLParserBuilder {
    static var styleAttributes: [HTMLTagStyleAttribute] {
        return [
            ColorHTMLTagStyleAttribute(),
            BackgroundColorHTMLTagStyleAttribute(),
            FontSizeHTMLTagStyleAttribute(),
            FontWeightHTMLTagStyleAttribute(),
            LineHeightHTMLTagStyleAttribute(),
            WordSpacingHTMLTagStyleAttribute(),
            FontFamilyHTMLTagStyleAttribute()
        ]
    }
}
