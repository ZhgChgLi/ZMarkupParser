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
    let indentSymobol: String
    let startingItemNumber: Int
    
    public init(type: MarkupStyleType = .disc, format: String = "%@\t", indentSymobol: String = "\t", startingItemNumber: Int = 1) {
        self.type = type
        self.format = format
        self.startingItemNumber = startingItemNumber
        self.indentSymobol = indentSymobol
    }
    
    func marker(forItemNumber: Int) -> String {
        return type.marker(forItemNumber: forItemNumber, startingItemNumber: startingItemNumber, format: format)
    }
    
    public enum MarkupStyleType {
        case custom(String)
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
            case .hyphen, .check, .circle, .disc, .diamond, .box, .square, .custom:
                return false
            }
        }
        
        func marker(forItemNumber: Int, startingItemNumber: Int, format: String) -> String {
            let string: String
            switch self {
            case .octal:
                let textList = NSTextList(markerFormat: .octal, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .lowercaseAlpha:
                let textList = NSTextList(markerFormat: .lowercaseAlpha, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .decimal:
                let textList = NSTextList(markerFormat: .decimal, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .lowercaseHexadecimal:
                let textList = NSTextList(markerFormat: .lowercaseHexadecimal, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .lowercaseLatin:
                let textList = NSTextList(markerFormat: .lowercaseLatin, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .lowercaseRoman:
                let textList = NSTextList(markerFormat: .lowercaseRoman, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .uppercaseAlpha:
                let textList = NSTextList(markerFormat: .uppercaseAlpha, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .uppercaseLatin:
                let textList = NSTextList(markerFormat: .uppercaseLatin, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .uppercaseRoman:
                let textList = NSTextList(markerFormat: .uppercaseRoman, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .uppercaseHexadecimal:
                let textList = NSTextList(markerFormat: .uppercaseHexadecimal, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .hyphen:
                let textList = NSTextList(markerFormat: .hyphen, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .check:
                let textList = NSTextList(markerFormat: .check, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .circle:
                let textList = NSTextList(markerFormat: .circle, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .disc:
                let textList = NSTextList(markerFormat: .disc, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .diamond:
                let textList = NSTextList(markerFormat: .diamond, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .box:
                let textList = NSTextList(markerFormat: .box, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .square:
                let textList = NSTextList(markerFormat: .square, options: 0)
                textList.startingItemNumber = startingItemNumber
                string = String(format: format, textList.marker(forItemNumber: forItemNumber))
            case .custom(let symbol):
                string = String(format: format, symbol)
            }
            
            return string
        }
    }

}
