//
//  MarkupStyleColor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/4.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct MarkupStyleColor {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: CGFloat
    
    init?(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        guard red >= 0 && red <= 255,
              green >= 0 && green <= 255,
              blue >= 0 && blue <= 255,
              alpha >= 0 && alpha <= 1 else {
            return nil
        }
        
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init?(name: MarkupStyleColorName) {
        let rgb = name.rgb
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: CGFloat(1.0))
    }
    
    public init?(vendor: MarkupStyleVendorColor) {
        let rgb = vendor.rgb
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: CGFloat(1.0))
    }
    
    public init?(sponsor: MarkupStyleSponsorColor) {
        let rgb = sponsor.rgb
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: CGFloat(1.0))
    }

    public init?(string: String) {
        let rgba: (Int,Int,Int,CGFloat)
        
        if let regex = try? NSRegularExpression(pattern: "#([0-9a-fA-F]+)"),
           let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
           firstMatch.range(at: 1).location != NSNotFound,
           let range = Range(firstMatch.range(at: 1), in: string) {
            // hex color string e.g. #ff00ff
            
            let hexString = String(string[range])
            var rgbValue: UInt64 = 0
            Scanner(string: hexString).scanHexInt64(&rgbValue)
            
            let red = Int((rgbValue & 0xFF0000) >> 16)
            let green = Int((rgbValue & 0x00FF00) >> 8)
            let blue = Int(rgbValue & 0x0000FF)
            let alpha = CGFloat(1.0)
            
            rgba = (red, green, blue, alpha)
        } else if let regex = try? NSRegularExpression(pattern: #"rgb\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*\)"#),
                  let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
                  firstMatch.range(at: 1).location != NSNotFound,
                  firstMatch.range(at: 2).location != NSNotFound,
                  firstMatch.range(at: 3).location != NSNotFound,
                  let rangeRed = Range(firstMatch.range(at: 1), in: string),
                  let rangeGreen = Range(firstMatch.range(at: 2), in: string),
                  let rangeBlue = Range(firstMatch.range(at: 3), in: string),
                  let red = Int(String(string[rangeRed])),
                  let green = Int(String(string[rangeGreen])),
                  let blue = Int(String(string[rangeBlue])) {
            // rgb e.g. rbg(255, 0, 0)
            
            rgba = (red, green, blue, 1.0)
        } else if let regex = try? NSRegularExpression(pattern: #"rgba\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9|\.]+)\s*\)"#),
                  let firstMatch = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
                  firstMatch.range(at: 1).location != NSNotFound,
                  firstMatch.range(at: 2).location != NSNotFound,
                  firstMatch.range(at: 3).location != NSNotFound,
                  firstMatch.range(at: 4).location != NSNotFound,
                  let rangeRed = Range(firstMatch.range(at: 1), in: string),
                  let rangeGreen = Range(firstMatch.range(at: 2), in: string),
                  let rangeBlue = Range(firstMatch.range(at: 3), in: string),
                  let rangeAlpha = Range(firstMatch.range(at: 4), in: string),
                  let red = Int(String(string[rangeRed])),
                  let green = Int(String(string[rangeGreen])),
                  let blue = Int(String(string[rangeBlue])),
                  let alpha = Float(String(string[rangeAlpha])) {
            // rgba e.g. rbga(255, 0, 0, 0.5)
            
            rgba = (red, green, blue, CGFloat(alpha))
        } else if let colorNameRGB = MarkupStyleColorName(string: string)?.rgb {
            rgba = (colorNameRGB.0, colorNameRGB.1, colorNameRGB.2, 1.0)
        } else {
            return nil
        }
        
        self.init(red: rgba.0, green: rgba.1, blue: rgba.2, alpha: rgba.3)
    }
}

#if canImport(UIKit)

extension MarkupStyleColor {
    
    public func getColor() -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    public init(color: UIColor) {
        let ciColor = CIColor(color: color)
        self.red = Int(ciColor.red * 255)
        self.green = Int(ciColor.green * 255)
        self.blue = Int(ciColor.blue * 255)
        self.alpha = ciColor.alpha
    }
}

#elseif canImport(AppKit)

extension MarkupStyleColor {

    public func getColor() -> NSColor {
        return NSColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    public init(color: NSColor) {
        let ciColor = CIColor(color: color)
        self.red = Int((ciColor?.red ?? 0) * 255)
        self.green = Int((ciColor?.green ?? 0) * 255)
        self.blue = Int((ciColor?.blue ?? 0) * 255)
        self.alpha = ciColor?.alpha ?? 1
    }
}

#endif
