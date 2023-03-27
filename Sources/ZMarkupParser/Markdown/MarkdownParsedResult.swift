//
//  MarkdownParsedResult.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

enum MarkdownParsedResult {
    case rawString(NSAttributedString)
    case url(URL)
    case symbol(MarkdownSymbol, Int) // length of symbol
}
