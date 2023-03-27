//
//  MarkdownParsedResult.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

enum MarkdownParsedResult {
    case rawString(NSAttributedString)
    case url(URL, NSAttributedString)
    case symbol(MarkdownSymbol, Int, NSAttributedString) // length of symbol
    
    case start(MarkdownElement)
    case close(MarkdownElement)
}
