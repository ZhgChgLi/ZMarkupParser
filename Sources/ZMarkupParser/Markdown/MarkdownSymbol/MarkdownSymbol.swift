//
//  MarkdownSymbol.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public protocol MarkdownSymbol {
    var regexString: String { get }
    func accept<V: MarkdownSymbolVisitor>(_ visitor: V) -> V.Result
}
