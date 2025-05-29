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

    typealias Result = MarkupStyle?
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    func visit(_ styleAttribute: ColorHTMLTagStyleAttribute) -> Result {
        guard let color = MarkupStyleColor(string: value) else { return nil }
        return MarkupStyle(foregroundColor: color)
    }
    
    func visit(_ styleAttribute: ExtendHTMLTagStyleAttribute) -> Result {
        return styleAttribute.render(value)
    }
    
    func visit(_ styleAttribute: BackgroundColorHTMLTagStyleAttribute) -> Result {
        guard let color = MarkupStyleColor(string: value) else { return nil }
        return MarkupStyle(backgroundColor: color)
    }
    
    func visit(_ styleAttribute: FontSizeHTMLTagStyleAttribute) -> Result {
        guard let size = self.convert(fromPX: value) else { return nil }
        return MarkupStyle(font: MarkupStyleFont(size: CGFloat(size)))
    }
    
    func visit(_ styleAttribute: ListStyleTypeHTMLTagStyleAttribute) -> MarkupStyle? {
        let type: MarkupStyleType
        switch value {
        case "disc":
            type = .disc
        case "square":
            type = .square
        case "circle":
            type = .circle
        case "decimal", "decimal-leading-zero":
            type = .decimal
        case "lower-alpha", "lower-greek":
            type = .lowercaseAlpha
        case "lower-latin":
            type = .lowercaseLatin
        case "lower-roman":
            type = .lowercaseRoman
        case "upper-alpha", "upper-greek":
            type = .uppercaseAlpha
        case "upper-latin":
            type = .uppercaseLatin
        case "upper-roman":
            type = .uppercaseRoman
        default:
            type = .decimal
        }
        return MarkupStyle(paragraphStyle: MarkupStyleParagraphStyle(textListStyleType: type))
    }
    
    func visit(_ styleAttribute: FontWeightHTMLTagStyleAttribute) -> Result {
        var weightStyle: FontWeightHTMLTagStyleAttribute.FontWeight?
        if let fontWeightStyle = FontWeightHTMLTagStyleAttribute.FontWeightStyle(rawValue: value) {
            weightStyle = .style(fontWeightStyle)
        } else if let fontWeightFloat = Float(value) {
            weightStyle = .rawValue(CGFloat(fontWeightFloat))
        }
        
        guard let weightStyle = weightStyle else { return nil }
        
        switch weightStyle {
        case .style(let style):
            switch style {
            case .bold:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.bold)))
            case .normal:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.regular)))
            }
        case .rawValue(let value):
            /*
             https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight#common_weight_name_mapping
             Value    Common weight name
             100    Thin (Hairline)
             200    Extra Light (Ultra Light)
             300    Light
             400    Normal (Regular)
             500    Medium
             600    Semi Bold (Demi Bold)
             700    Bold
             800    Extra Bold (Ultra Bold)
             900    Black (Heavy)
             950    Extra Black (Ultra Black)
             */
            switch value {
            case 100:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.thin)))
            case 200:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.ultraLight)))
            case 300:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.light)))
            case 400:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.regular)))
            case 500:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.medium)))
            case 600:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.semibold)))
            case 700:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.bold)))
            case 800:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.heavy)))
            case 900:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.black)))
            case 950:
                return MarkupStyle(font: MarkupStyleFont(weight: .style(.black)))
            default:
                return MarkupStyle(font: MarkupStyleFont(weight: .rawValue(value)))
            }
        }
    }

    func visit(_ styleAttribute: FontFamilyHTMLTagStyleAttribute) -> MarkupStyle? {
        // e.g. "Times New Roman", Times, serif
        // use first match font
        
        let pattern = "(')*(?<fontName>[^',]+)(\\1)*"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let matches = regex.matches(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count))

        var fontFamilies: [String] = []
        for match in matches {
            if match.range(withName: "fontName").location != NSNotFound,
               let range = Range(match.range(withName: "fontName"), in: value) {
                fontFamilies.append(String(value[range]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        if fontFamilies.count <= 0 {
            return nil
        } else {
            return MarkupStyle(font: .init(familyName: .familyNames(fontFamilies)))
        }
        
    }
    
    func visit(_ styleAttribute: LineHeightHTMLTagStyleAttribute) -> Result {
        guard let lineHeightFloat = self.convert(fromPX: value) else { return nil }
        return MarkupStyle(paragraphStyle: MarkupStyleParagraphStyle(minimumLineHeight: lineHeightFloat, maximumLineHeight: lineHeightFloat))
    }
    
    func visit(_ styleAttribute: WordSpacingHTMLTagStyleAttribute) -> Result {
        guard let lineSpacing = self.convert(fromPX: value) else { return nil }
        return MarkupStyle(paragraphStyle: MarkupStyleParagraphStyle(lineSpacing: lineSpacing))
    }
    
    func convert(fromPX string: String) -> CGFloat? {
        guard let regex = try? NSRegularExpression(pattern: "([0-9]+.?[0-9]*)p(x|t)"),
              let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)),
              firstMatch.range(at: 1).location != NSNotFound,
              let range = Range(firstMatch.range(at: 1), in: string),
              let size = Float(String(string[range])) else {
            return nil
        }
        return CGFloat(size)
    }

    func visit(_ styleAttribute: TextAlignHTMLTagStyleAttribute) -> MarkupStyle? {
         return MarkupStyle(
             paragraphStyle: MarkupStyleParagraphStyle(
                 alignment: convertAlign(align: value)
             )
         )
     }

    private func convertAlign(align: String) -> NSTextAlignment? {
         switch align {
         case "center":
             return .center
         case "justified":
             return .justified
         case "natural":
             return .natural
         case "right", "end":
             return .right
         case "left", "start":
             return .left
         default:
             return nil
         }
     }
}
