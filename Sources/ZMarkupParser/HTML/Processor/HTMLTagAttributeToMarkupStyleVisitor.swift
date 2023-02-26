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
        return styleAttribute.render(fromStyle, value)
    }
    
    func visit(_ styleAttribute: BackgroundColorHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let color = MarkupStyleColor(string: value) else { return newStyle }
        newStyle.backgroundColor = color
        return newStyle
    }
    
    func visit(_ styleAttribute: FontSizeHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let size = self.convert(fromPX: value) else { return newStyle }
        newStyle.font.size = CGFloat(size)
        return newStyle
    }
    
    func visit(_ styleAttribute: FontWeightHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        var weightStyle: FontWeightHTMLTagStyleAttribute.FontWeight?
        if let fontWeightStyle = FontWeightHTMLTagStyleAttribute.FontWeightStyle(rawValue: value) {
            weightStyle = .style(fontWeightStyle)
        } else if let fontWeightFloat = Float(value) {
            weightStyle = .rawValue(CGFloat(fontWeightFloat))
        }
        
        guard let weightStyle = weightStyle else { return newStyle }
        
        switch weightStyle {
        case .style(let style):
            switch style {
            case .bold:
                newStyle.font.weight = .style(.bold)
            case .normal:
                newStyle.font.weight = .style(.regular)
            }
        case .rawValue(let value):
            newStyle.font.weight = .rawValue(value)
        }
        
        return newStyle
    }
    
    func visit(_ styleAttribute: LineHeightHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let lineHeightFloat = Float(value) else { return newStyle }
        newStyle.paragraphStyle.minimumLineHeight = CGFloat(lineHeightFloat)
        newStyle.paragraphStyle.maximumLineHeight = CGFloat(lineHeightFloat)
        return newStyle
    }
    
    func visit(_ styleAttribute: WordSpacingHTMLTagStyleAttribute) -> Result {
        var newStyle = fromStyle
        guard let lineSpacing = self.convert(fromPX: value) else { return newStyle }
        newStyle.paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        return newStyle
    }
    
    func convert(fromPX string: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: "([0-9]+)px"),
              let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
              firstMatch.range(at: 1).location != NSNotFound,
              let range = Range(firstMatch.range(at: 1), in: string),
              let size = Float(String(string[range])) else {
            return nil
        }
        return Int(size)
    }
}
