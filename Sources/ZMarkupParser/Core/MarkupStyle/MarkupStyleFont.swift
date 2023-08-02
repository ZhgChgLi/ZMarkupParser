//
//  MarkupStyleFont.swift
//
//
//  Created by https://zhgchg.li on 2023/2/4.
//
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct MarkupStyleFont: MarkupStyleItem {
    public enum CaseStyle {
        case lowercase
        case uppercase
    }
    public enum FontWeight {
        case style(FontWeightStyle)
        case rawValue(CGFloat)
    }
    public enum FontFamily {
        case familyNames([String])
        
        #if canImport(UIKit)
        func getFont(size: CGFloat) -> UIFont? {
            switch self {
            case .familyNames(let familyNames):
                for familyName in familyNames {
                    if let font = UIFont(name: familyName, size: size) {
                        return font
                    }
                }
                return nil
            }
        }
        #elseif canImport(AppKit)
        func getFont(size: CGFloat) -> NSFont? {
            switch self {
            case .familyNames(let familyNames):
                for familyName in familyNames {
                    if let font = NSFont(name: familyName, size: size) {
                        return font
                    }
                }
                return nil
            }
        }
        #endif
    }
    public enum FontWeightStyle: String {
        case ultraLight, light, thin, regular, medium, semibold, bold, heavy, black
        
        #if canImport(UIKit)
        init?(font: UIFont) {
            guard let weightName = font.fontDescriptor.object(forKey: .face) as? String else {
                return nil
            }
            self.init(rawValue: weightName.lowercased())
        }
        #elseif canImport(AppKit)
        init?(font: NSFont) {
            guard let weightName = font.fontDescriptor.object(forKey: .face) as? String else {
                return nil
            }
            self.init(rawValue: weightName.lowercased())
        }
        #endif

    }
    
    public var size: CGFloat?
    public var weight: FontWeight?
    public var italic: Bool?
    public var familyName: FontFamily?
    
    public init(size: CGFloat? = nil, weight: FontWeight? = nil, italic: Bool? = nil, familyName: FontFamily? = nil) {
        self.size = size
        self.weight = weight
        self.italic = italic
        self.familyName = familyName
    }
    
    mutating func fillIfNil(from: MarkupStyleFont?) {
        self.size = self.size ?? from?.size
        self.weight = self.weight ?? from?.weight
        self.italic = self.italic ?? from?.italic
        self.familyName = self.familyName ?? from?.familyName
    }
    
    func isNil() -> Bool {
        return !([size,
                 weight,
                 italic,
                 familyName] as [Any?]).contains(where: { $0 != nil})
    }
}

#if canImport(UIKit)

extension MarkupStyleFont {
    
    public init(_ font: UIFont) {
        self.size = font.pointSize
        self.italic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        if let fontWeight = FontWeightStyle.init(font: font) {
            self.weight = FontWeight.style(fontWeight)
        }
        self.familyName = .familyNames([font.familyName])
    }
    
    func getFont() -> UIFont? {
        guard !isNil() else { return nil }
        
        let size = (self.size ?? MarkupStyle.default.font.size) ?? UIFont.systemFontSize
        
        // There is no direct method in UIFont to specify the font family, italic and weight together.
        
        if let italic = self.italic, italic == true {
            // italic
            
            let font: UIFont
            if let familyFont = self.familyName?.getFont(size: size) {
                font = familyFont
            } else {
                font = UIFont.systemFont(ofSize: size)
            }
            
            if let weight = self.weight {
                let needBold: Bool
                switch weight {
                case .style(let style):
                    switch style {
                    case .ultraLight, .light, .thin, .regular:
                        needBold = false
                    case .medium, .semibold, .bold, .heavy, .black:
                        needBold = true
                    }
                case .rawValue(let value):
                    if value < UIFont.Weight.medium.rawValue {
                        needBold = false
                    } else {
                        needBold = true
                    }
                }
                
                if needBold {
                    // italic+bold
                    return withTraits(font: font, traits: .traitItalic, .traitBold)
                } else {
                    // italic
                    return withTraits(font: font, traits: .traitItalic)
                }
            } else {
                // italic
                return withTraits(font: font, traits: .traitItalic)
            }
        } else {
            if let familyFont = self.familyName?.getFont(size: size) {
                if let _ = self.weight {
                    // weight
                    return withTraits(font: familyFont, traits: .traitBold)
                } else {
                    // normal
                    return familyFont
                }
            } else {
                if let weight = self.weight {
                    // weight
                    return UIFont.systemFont(ofSize: size, weight: weight.convertToUIFontWeight())
                } else {
                    // normal
                    return UIFont.systemFont(ofSize: size)
                }
            }
        }
    }
    
    private func withTraits(font: UIFont, traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = font.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else {
            return font
        }
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }
}

public extension MarkupStyleFont.FontWeight {
    func convertToUIFontWeight() -> UIFont.Weight {
        switch self {
        case .style(let style):
            switch style {
            case .regular:
                return .regular
            case .ultraLight:
                return .ultraLight
            case .light:
                return .light
            case .thin:
                return .thin
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            case .heavy:
                return .heavy
            case .black:
                return .black
            }
        case .rawValue(let value):
            return UIFont.Weight(rawValue: value)
        }
    }
}

#elseif canImport(AppKit)

extension MarkupStyleFont {
    public init(_ font: NSFont) {
        self.size = font.pointSize
        self.italic = font.fontDescriptor.symbolicTraits.contains(.italic)
        if let fontWeight = FontWeightStyle.init(font: font) {
            self.weight = FontWeight.style(fontWeight)
        }
        if let familyName = font.familyName {
            self.familyName = .familyNames([familyName])
        }
    }
    
    func getFont() -> NSFont? {
        guard !isNil() else { return nil }
        
        let size = (self.size ?? MarkupStyle.default.font.size) ?? NSFont.systemFontSize
        
        // There is no direct method in UIFont to specify the font family, italic and weight together.
        
        if let italic = self.italic, italic == true {
            // italic
            
            let font: NSFont
            if let familyFont = self.familyName?.getFont(size: size) {
                font = familyFont
            } else {
                font = NSFont.systemFont(ofSize: size)
            }
            
            if let weight = self.weight {
                let needBold: Bool
                switch weight {
                case .style(let style):
                    switch style {
                    case .ultraLight, .light, .thin, .regular:
                        needBold = false
                    case .medium, .semibold, .bold, .heavy, .black:
                        needBold = true
                    }
                case .rawValue(let value):
                    if value < NSFont.Weight.medium.rawValue {
                        needBold = false
                    } else {
                        needBold = true
                    }
                }
                
                if needBold {
                    // italic+bold
                    return withTraits(font: font, traits: .italic, .bold)
                } else {
                    // italic
                    return withTraits(font: font, traits: .italic)
                }
            } else {
                // italic
                return withTraits(font: font, traits: .italic)
            }
        } else {
            if let familyFont = self.familyName?.getFont(size: size) {
                if let _ = self.weight {
                    // weight
                    return withTraits(font: familyFont, traits: .bold)
                } else {
                    // normal
                    return familyFont
                }
            } else {
                if let weight = self.weight {
                    // weight
                    return NSFont.systemFont(ofSize: size, weight: weight.convertToUIFontWeight())
                } else {
                    // normal
                    return NSFont.systemFont(ofSize: size)
                }
            }
        }
    }
    
    private func withTraits(font: NSFont, traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
         let descriptor = font.fontDescriptor.withSymbolicTraits(NSFontDescriptor.SymbolicTraits(traits))
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
    }
}

public extension MarkupStyleFont.FontWeight {
    func convertToUIFontWeight() -> NSFont.Weight {
        switch self {
        case .style(let style):
            switch style {
            case .regular:
                return .regular
            case .ultraLight:
                return .ultraLight
            case .light:
                return .light
            case .thin:
                return .thin
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            case .heavy:
                return .heavy
            case .black:
                return .black
            }
        case .rawValue(let value):
            return NSFont.Weight(rawValue: value)
        }
    }
}

#endif
