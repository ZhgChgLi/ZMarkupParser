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

public enum MarkupStyleType: String {
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
        case .hyphen, .check, .circle, .disc, .diamond, .box, .square:
            return false
        }
    }
    
    func getString(startingItemNumber: Int, forItemNumber: Int) -> String {
        // We only NSTextList to generate symbol, because NSTextList have abnormal extra spaces.
        // ref: https://stackoverflow.com/questions/66714650/nstextlist-formatting
        let textList: NSTextList = NSTextList(markerFormat: self.getMarkerFormat(), options: 0)
        textList.startingItemNumber = startingItemNumber
       
        return String(format: self.getFormat(), textList.marker(forItemNumber: forItemNumber))
    }
    
    func getFormat() -> String {
        return (isOrder()) ? ("\t%@.\t") : ("\t%@\t")
    }
    
    func getMarkerFormat() -> NSTextList.MarkerFormat {
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
