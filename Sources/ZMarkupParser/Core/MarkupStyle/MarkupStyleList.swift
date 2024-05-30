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
    case custom(String)
    
    public init?(format: NSTextList.MarkerFormat) {
        switch format {
        case .octal:
            self = .octal
        case .lowercaseAlpha:
            self = .lowercaseAlpha
        case .decimal:
            self = .decimal
        case .lowercaseHexadecimal:
            self = .lowercaseHexadecimal
        case .lowercaseLatin:
            self = .lowercaseLatin
        case .lowercaseRoman:
            self = .lowercaseRoman
        case .uppercaseAlpha:
            self = .uppercaseAlpha
        case .uppercaseLatin:
            self = .uppercaseLatin
        case .uppercaseRoman:
            self = .uppercaseRoman
        case .uppercaseHexadecimal:
            self = .uppercaseHexadecimal
        case .hyphen:
            self = .hyphen
        case .check:
            self = .check
        case .circle:
            self = .circle
        case .disc:
            self = .disc
        case .diamond:
            self = .diamond
        case .box:
            self = .box
        case .square:
            self = .square
        default:
            return nil
        }
    }
    
    func isOrder() -> Bool {
        switch self {
        case .octal,.lowercaseAlpha,.decimal,.lowercaseHexadecimal,.lowercaseLatin,.lowercaseRoman,.uppercaseAlpha,.uppercaseLatin,.uppercaseRoman,.uppercaseHexadecimal:
            return true
        case .hyphen, .check, .circle, .disc, .diamond, .box, .square, .custom:
            return false
        }
    }
    
    func getItem(startingItemNumber: Int, forItemNumber: Int) -> String {
        // We only NSTextList to generate symbol, because NSTextList have abnormal extra spaces.
        // ref: https://stackoverflow.com/questions/66714650/nstextlist-formatting
        switch self {
        case .octal:
            let textList = NSTextList(markerFormat: .octal, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .lowercaseAlpha:
            let textList = NSTextList(markerFormat: .lowercaseAlpha, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .decimal:
            let textList = NSTextList(markerFormat: .decimal, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .lowercaseHexadecimal:
            let textList = NSTextList(markerFormat: .lowercaseHexadecimal, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .lowercaseLatin:
            let textList = NSTextList(markerFormat: .lowercaseLatin, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .lowercaseRoman:
            let textList = NSTextList(markerFormat: .lowercaseRoman, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .uppercaseAlpha:
            let textList = NSTextList(markerFormat: .uppercaseAlpha, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .uppercaseLatin:
            let textList = NSTextList(markerFormat: .uppercaseLatin, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .uppercaseRoman:
            let textList = NSTextList(markerFormat: .uppercaseRoman, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .uppercaseHexadecimal:
            let textList = NSTextList(markerFormat: .uppercaseHexadecimal, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .hyphen:
            let textList = NSTextList(markerFormat: .hyphen, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .check:
            let textList = NSTextList(markerFormat: .check, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .circle:
            let textList = NSTextList(markerFormat: .circle, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .disc:
            let textList = NSTextList(markerFormat: .disc, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .diamond:
            let textList = NSTextList(markerFormat: .diamond, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .box:
            let textList = NSTextList(markerFormat: .box, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .square:
            let textList = NSTextList(markerFormat: .square, options: 0)
            textList.startingItemNumber = startingItemNumber
            return textList.marker(forItemNumber: forItemNumber)
        case .custom(let custom):
            return custom
        }
    }
    
    func getFormat() -> String {
        return (isOrder()) ? ("\t%@.\t") : ("\t%@\t")
    }
}
