//
//  LinkMarkdownSymbol.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct LinkMarkdownSymbol: MarkdownSymbol {
    static let contentRegexGroupName = "linkContent"
    static let urlRegexGroupName = "linkURLContent"
    
    public let regexString: String = "\\[(?<\(Self.contentRegexGroupName)>[^\\]]*)\\]\\((?<\(Self.urlRegexGroupName)>https?:\\/\\/(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&\\/=]*))([^\\)]*)\\)"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : MarkdownSymbolVisitor {
        return visitor.visit(self)
    }
}
