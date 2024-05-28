//
//  MarkupStyleList.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/9.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct MarkupStyleList {
    let type: MarkupStyleType
    let headIndentMultiply: CGFloat
    let indentMultiply: CGFloat
    let startingItemNumber: Int
    
    /// {headIndentMultiply} - {indentMultiply} List Item 1
    /// {headIndentMultiply} - {indentMultiply} List Item 2
    /// mutiply base size is current font size
    public init(type: MarkupStyleType = .disc, headIndentMultiply: CGFloat = 0.25, indentMultiply: CGFloat = 0.5, startingItemNumber: Int = 1) {
        self.type = type
        self.headIndentMultiply = headIndentMultiply
        self.startingItemNumber = startingItemNumber
        self.indentMultiply = indentMultiply
    }
    
    func marker(forItemNumber: Int) -> String {
        return type.marker(forItemNumber: forItemNumber, startingItemNumber: startingItemNumber)
    }
    
    // due to tab width caculator, we can't provide custom(String)
    public enum MarkupStyleType {
        case octal
        case lowercaseAlpha
        case decimal
        case lowercaseHexadecimal
        case lowercaseLatin
        case lowercaseRoman
        case uppercaseAlpha
        case uppercaseLatin
        case uppercaseRoman
        case uppercaseHexadecimal
        case hyphen
        case check
        case circle
        case disc
        case diamond
        case box
        case square
        
        func isOrder() -> Bool {
            switch self {
            case .octal,.lowercaseAlpha,.decimal,.lowercaseHexadecimal,.lowercaseLatin,.lowercaseRoman,.uppercaseAlpha,.uppercaseLatin,.uppercaseRoman,.uppercaseHexadecimal:
                return true
            case .hyphen, .check, .circle, .disc, .diamond, .box, .square:
                return false
            }
        }
        
        func marker(forItemNumber: Int, startingItemNumber: Int) -> String {
            let textList: NSTextList
            switch self {
            case .octal:
                textList = NSTextList(markerFormat: .octal, options: 0)
            case .lowercaseAlpha:
                textList = NSTextList(markerFormat: .lowercaseAlpha, options: 0)
            case .decimal:
                textList = NSTextList(markerFormat: .decimal, options: 0)
            case .lowercaseHexadecimal:
                textList = NSTextList(markerFormat: .lowercaseHexadecimal, options: 0)
            case .lowercaseLatin:
                textList = NSTextList(markerFormat: .lowercaseLatin, options: 0)
            case .lowercaseRoman:
                textList = NSTextList(markerFormat: .lowercaseRoman, options: 0)
            case .uppercaseAlpha:
                textList = NSTextList(markerFormat: .uppercaseAlpha, options: 0)
            case .uppercaseLatin:
                textList = NSTextList(markerFormat: .uppercaseLatin, options: 0)
            case .uppercaseRoman:
                textList = NSTextList(markerFormat: .uppercaseRoman, options: 0)
            case .uppercaseHexadecimal:
                textList = NSTextList(markerFormat: .uppercaseHexadecimal, options: 0)
            case .hyphen:
                textList = NSTextList(markerFormat: .hyphen, options: 0)
            case .check:
                textList = NSTextList(markerFormat: .check, options: 0)
            case .circle:
                textList = NSTextList(markerFormat: .circle, options: 0)
            case .disc:
                textList = NSTextList(markerFormat: .disc, options: 0)
            case .diamond:
                textList = NSTextList(markerFormat: .diamond, options: 0)
            case .box:
                textList = NSTextList(markerFormat: .box, options: 0)
            case .square:
                textList = NSTextList(markerFormat: .square, options: 0)
            }
            
            textList.startingItemNumber = startingItemNumber
            let format = (isOrder()) ? ("\t%@.\t") : ("\t%@\t")
            return String(format: format, textList.marker(forItemNumber: forItemNumber))
        }
    }

}
