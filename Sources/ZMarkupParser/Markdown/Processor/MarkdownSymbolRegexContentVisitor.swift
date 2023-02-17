//
//  MarkdownSymbolContentVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

struct MarkdownSymbolRegexContentVisitor: MarkdownSymbolVisitor {
    typealias Result = NSAttributedString?
    
    let attributedString: NSAttributedString
    let matchResult: NSTextCheckingResult
    init(attributedString: NSAttributedString, matchResult: NSTextCheckingResult) {
        self.attributedString = attributedString
        self.matchResult = matchResult
    }
    
    func visit(_ symbol: BoldMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: BoldMarkdownSymbol.contentRegexGroupName)
    }
    
    func visit(_ symbol: ItalicMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: ItalicMarkdownSymbol.contentRegexGroupName)
    }
    
    func visit(_ symbol: UnderlineMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: UnderlineMarkdownSymbol.contentRegexGroupName)
    }
    
    func visit(_ symbol: DeletelineMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: DeletelineMarkdownSymbol.contentRegexGroupName)
    }
    
    func visit(_ symbol: LinkMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: LinkMarkdownSymbol.contentRegexGroupName)
    }
    
    func visit(_ symbol: ExtendMarkdownSymbol) -> Result {
        return matchResult.attributedString(attributedString, with: symbol.contentRegexGroupName)
    }
}
