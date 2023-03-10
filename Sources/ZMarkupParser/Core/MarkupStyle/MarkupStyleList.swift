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
    let format: String
    let startingItemNumber: Int
    
    public init(type: MarkupStyleType, format: String, startingItemNumber: Int) {
        self.type = type
        self.format = format
        self.startingItemNumber = startingItemNumber
    }
    
    func marker(forItemNumber: Int) -> String {
        return type.marker(forItemNumber: forItemNumber, startingItemNumber: startingItemNumber, format: format)
    }
    
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
        
        func marker(forItemNumber: Int, startingItemNumber: Int, format: String) -> String {
            let textList = NSTextList(markerFormat: self.markerFormat(), options: 0)
            textList.startingItemNumber = startingItemNumber
            return String(format: format, textList.marker(forItemNumber: forItemNumber))
        }
        
        private func markerFormat() -> NSTextList.MarkerFormat {
            switch self {
            case .octal:
                return .octal
            case .lowercaseAlpha:
                return .lowercaseAlpha
            case .decimal:
                return .decimal
            case .lowercaseHexadecimal:
                return .lowercaseHexadecimal
            case .lowercaseLatin:
                return .lowercaseLatin
            case .lowercaseRoman:
                return .lowercaseRoman
            case .uppercaseAlpha:
                return .uppercaseAlpha
            case .uppercaseLatin:
                return .uppercaseLatin
            case .uppercaseRoman:
                return .uppercaseRoman
            case .uppercaseHexadecimal:
                return .uppercaseHexadecimal
            case .hyphen:
                return .hyphen
            case .check:
                return .check
            case .circle:
                return .circle
            case .disc:
                return .disc
            case .diamond:
                return .diamond
            case .box:
                return .box
            case .square:
                return .square
            }
        }
    }

}
