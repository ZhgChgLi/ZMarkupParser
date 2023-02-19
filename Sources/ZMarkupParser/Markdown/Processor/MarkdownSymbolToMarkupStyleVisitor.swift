//
//  MarkdownSymbolToMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

struct MarkdownSymbolToMarkupStyleVisitor: MarkdownSymbolVisitor {
    typealias Result = MarkupStyle?
    
    let attributedString: NSAttributedString
    let matchResult: NSTextCheckingResult
    init(attributedString: NSAttributedString, matchResult: NSTextCheckingResult) {
        self.attributedString = attributedString
        self.matchResult = matchResult
    }
    
    func visit(_ symbol: BoldMarkdownSymbol) -> Result {
        return MarkupStyle.bold
    }
    
    func visit(_ symbol: ItalicMarkdownSymbol) -> Result {
        return MarkupStyle.italic
    }
    
    func visit(_ symbol: UnderlineMarkdownSymbol) -> Result {
        return MarkupStyle.underline
    }
    
    func visit(_ symbol: DeletelineMarkdownSymbol) -> Result {
        return MarkupStyle.deleteline
    }
    
    func visit(_ symbol: LinkMarkdownSymbol) -> MarkupStyle? {
        guard let urlString = matchResult.attributedString(attributedString, with: LinkMarkdownSymbol.urlRegexGroupName)?.string,
           let url = URL(string: urlString) else {
            return nil
        }
        var style = MarkupStyle.link
        style.link = url
        return style
    }
    
    func visit(_ symbol: ExtendMarkdownSymbol) -> MarkupStyle? {
        return nil
    }
}
