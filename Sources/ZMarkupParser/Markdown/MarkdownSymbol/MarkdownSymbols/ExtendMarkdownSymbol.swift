//
//  ExtendMarkdownSymbol.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct ExtendMarkdownSymbol: MarkdownSymbol {
    public enum ExtendMarkdownSymbolError: Error {
        case contentRegexGroupNameIsNotPresentInRegularExpressionPatternString
    }
    
    public let regexString: String
    public let contentRegexGroupName: String
    
    public init(expression: NSRegularExpression, contentRegexGroupName: String) throws {
        let regexString = expression.pattern
        guard regexString.contains(contentRegexGroupName) else {
            throw ExtendMarkdownSymbolError.contentRegexGroupNameIsNotPresentInRegularExpressionPatternString
        }
        
        self.regexString = regexString
        self.contentRegexGroupName = contentRegexGroupName
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : MarkdownSymbolVisitor {
        return visitor.visit(self)
    }
}

