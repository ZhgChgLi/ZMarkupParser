//
//  MarkdownSymbol.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

enum MarkdownSymbol: String, CaseIterable {
    case asterisk = "*"
    case dashes = "-"
    case leftParenthesis = "("
    case rightParenthesis = ")"
    case exclamation = "!"
    case leftSquareBracket = "["
    case rightSquareBracket = "]"
    case space = " "
    case breakline = "\n"
    case hash = "#"
    
    static func pattern() -> String {
        Self.allCases.map({ "(?<\($0.groupName())>\($0.regex())+)" }).joined(separator: "|")
    }
    
    init?(_ checkResult: NSTextCheckingResult) {
        guard let symbol = Self.allCases.first(where: { checkResult.range(withName: $0.groupName()).location != NSNotFound }) else {
            return nil
        }
        self = symbol
    }
    
    func regex() -> String {
        switch self {
        case .space:
            return "\\s"
        default:
            return "\\\(self.rawValue)"
        }
    }
    
    func groupName() -> String {
        switch self {
        case .asterisk:
            return "asterisk"
        case .dashes:
            return "dashes"
        case .leftParenthesis:
            return "leftParenthesis"
        case .rightParenthesis:
            return "rightParenthesis"
        case .exclamation:
            return "exclamation"
        case .leftSquareBracket:
            return "leftSquareBracket"
        case .rightSquareBracket:
            return "rightSquareBracket"
        case .hash:
            return "hash"
        case .space:
            return "space"
        case .breakline:
            return "breakline"
        }
    }
}
