//
//  ItalicMarkdownSymbol.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct ItalicMarkdownSymbol: MarkdownSymbol {
    static let contentRegexGroupName = "italicContent"
    public let regexString: String = "\\*{1}(?<\(Self.contentRegexGroupName)>[^(\\*]+)\\*{1}"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : MarkdownSymbolVisitor {
        return visitor.visit(self)
    }
}
