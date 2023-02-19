//
//  MarkdownSymbolToMarkupVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

struct MarkdownSymbolToMarkupVisitor: MarkdownSymbolVisitor {
    typealias Result = Markup
    
    let style: MarkupStyle?
    init(style: MarkupStyle?) {
        self.style = style
    }
    
    func visit(_ symbol: BoldMarkdownSymbol) -> Result {
        return BoldMarkup(style: style)
    }
    
    func visit(_ symbol: ItalicMarkdownSymbol) -> Result {
        return ItalicMarkup(style: style)
    }
    
    func visit(_ symbol: UnderlineMarkdownSymbol) -> Result {
        return UnderlineMarkup(style: style)
    }
    
    func visit(_ symbol: DeletelineMarkdownSymbol) -> Result {
        return DeletelineMarkup(style: style)
    }
    
    func visit(_ symbol: LinkMarkdownSymbol) -> Result {
        return LinkMarkup(style: style)
    }
    
    func visit(_ symbol: ExtendMarkdownSymbol) -> Result {
        return ExtendMarkup(style: style)
    }
}
