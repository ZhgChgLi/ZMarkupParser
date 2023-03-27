//
//  MarkdownStringToParsedResult.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

final class MarkdownStringToParsedResult: ParserProcessor {
    typealias From = NSAttributedString
    typealias To = [MarkdownParsedResult]
    
    private lazy var urlRegularExpression = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    private lazy var symbolsPattern = MarkdownSymbol.pattern()
        
    func process(from: From) -> To {
        var items: [MarkdownParsedResult] = []
        guard let urlRegxr = ParserRegexr(attributedString: from, expression: self.urlRegularExpression) else {
            return items
        }
        
        urlRegxr.enumerateMatches { urlMatch in
            switch urlMatch {
            case .rawString(let urlRawString):
                if let regxr = ParserRegexr(attributedString: urlRawString, pattern: self.symbolsPattern) {
                    regxr.enumerateMatches { match in
                        switch match {
                        case .rawString(let rawString):
                            items.append(.rawString(rawString))
                        case .match(let matchResult):
                            let matchAttributedString = matchResult.attributedString(from, with: matchResult.range)
                            if let symbol = MarkdownSymbol(matchResult) {
                                items.append(.symbol(symbol, matchResult.range.length))
                            } else if let matchAttributedString = matchAttributedString {
                                items.append(.rawString(matchAttributedString))
                            }
                        }
                    }
                } else {
                    items.append(.rawString(urlRawString))
                }
            case .match(let urlMatchResult):
                if let urlAttributedString = urlMatchResult.attributedString(from, with: urlMatchResult.range) {
                    if let url = URL(string: urlAttributedString.string) {
                        items.append(.url(url))
                    } else {
                        items.append(.rawString(urlAttributedString))
                    }
                }
            }
        }
        
        return items
    }
}
