//
//  UnderlineMarkdownSymbol.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct UnderlineMarkdownSymbol: MarkdownSymbol {
    static let contentRegexGroupName = "underlinContent"
    public let regexString: String = "\\_\\_{1}(?<\(Self.contentRegexGroupName)>[^(\\_\\_]+)\\_\\_{1}"
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : MarkdownSymbolVisitor {
        return visitor.visit(self)
    }
}
