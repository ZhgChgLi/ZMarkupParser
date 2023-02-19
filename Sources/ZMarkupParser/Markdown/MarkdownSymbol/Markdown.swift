//
//  Markdown.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

struct Markdown {
    let symbol: MarkdownSymbol
    let customStyle: MarkupStyle?
    
    init(symbol: MarkdownSymbol, customStyle: MarkupStyle? = nil) {
        self.symbol = symbol
        self.customStyle = customStyle
    }
}

