//
//  HTMLTagAttributeToMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/1.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct HTMLTagStyleAttributeToMarkupStyleVisitor: HTMLTagStyleAttributeVisitor {
    typealias Result = MarkupStyle
    
    let fromStyle: MarkupStyle
    let value: String
    
    init(fromStyle: MarkupStyle, value: String) {
        self.fromStyle = fromStyle
        self.value = value
    }
    
    func visit(_ styleAttribute: ColorHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let color = MarkupStyleColor(string: value) else { return newStyle }
        newStyle.foregroundColor = color
        return newStyle
    }
    
    func visit(_ styleAttribute: ExtendHTMLTagStyleAttribute) -> Result {
        guard var styleAttributeStyle = styleAttribute.style else {
            return fromStyle
        }
        styleAttributeStyle.fillIfNil(from: fromStyle)
        return styleAttributeStyle
    }
    
    func visit(_ styleAttribute: BackgroundColorHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let color = MarkupStyleColor(string: value) else { return newStyle }
        newStyle.backgroundColor = color
        return newStyle
    }
    
    func visit(_ styleAttribute: FontSizeHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let size = self.convert(fromPT: value) else { return newStyle }
        newStyle.font.size = CGFloat(size)
        return newStyle
    }
    
    func visit(_ styleAttribute: FontWeightHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let weight = self.convert(fromPT: value) else { return newStyle }
        newStyle.font = MarkupStyleFont(weight: .rawValue(CGFloat(weight)))
        return newStyle
    }
    
    func visit(_ styleAttribute: LineHeightHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let lineHeight = self.convert(fromPT: value) else { return newStyle }
        newStyle.paragraphStyle.minimumLineHeight = CGFloat(lineHeight)
        newStyle.paragraphStyle.maximumLineHeight = CGFloat(lineHeight)
        return newStyle
    }
    
    func visit(_ styleAttribute: WordSpacingHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let lineSpacing = self.convert(fromPT: value) else { return newStyle }
        newStyle.paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        return newStyle
    }
    
    func convert(fromPT string: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: "([0-9]+)pt"),
              let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
              firstMatch.range(at: 1).location != NSNotFound,
              let range = Range(firstMatch.range(at: 1), in: string),
              let size = Float(String(string[range])) else {
            return nil
        }
        return Int(size)
    }
}
