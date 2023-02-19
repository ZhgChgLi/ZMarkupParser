//
//  MarkdownSymbolVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public protocol MarkdownSymbolVisitor {
    associatedtype Result
        
    func visit(symbol: MarkdownSymbol) -> Result
    func visit(_ symbol: ExtendMarkdownSymbol) -> Result
    
    func visit(_ symbol: BoldMarkdownSymbol) -> Result
    func visit(_ symbol: ItalicMarkdownSymbol) -> Result
    func visit(_ symbol: UnderlineMarkdownSymbol) -> Result
    func visit(_ symbol: DeletelineMarkdownSymbol) -> Result
    func visit(_ symbol: LinkMarkdownSymbol) -> Result
}

public extension MarkdownSymbolVisitor {
    func visit(symbol: MarkdownSymbol) -> Result {
        return symbol.accept(self)
    }
}

public extension ZMarkdownParserBuilder {
    static var markdownSymbols: [MarkdownSymbol] {
        return [
            BoldMarkdownSymbol(),
            ItalicMarkdownSymbol(),
            UnderlineMarkdownSymbol(),
            DeletelineMarkdownSymbol(),
            LinkMarkdownSymbol()
        ]
    }
}
