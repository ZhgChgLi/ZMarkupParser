//
//  StringParserRegexr.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/9.
//

import Foundation

struct ParserRegexr {
    enum MatchType {
        case rawString(NSAttributedString)
        case match(NSTextCheckingResult)
    }
    
    let attributedString: NSAttributedString
    let expression: NSRegularExpression
    
    var totoalLength: Int {
        return self.attributedString.string.utf16.count
    }
    
    init?(attributedString: NSAttributedString, expression: NSRegularExpression?) {
        guard let expression = expression else { return nil }
        self.expression = expression
        self.attributedString = attributedString
    }
    
    init?(attributedString: NSAttributedString, pattern: String, expressionOptions: NSRegularExpression.Options = [.caseInsensitive, .dotMatchesLineSeparators]) {
        guard let expression = try? NSRegularExpression(pattern: pattern, options: expressionOptions) else {
            return nil
        }
        self.expression = expression
        self.attributedString = attributedString
    }
    
    func enumerateMatches(using block: (MatchType) -> Void) {
        var lastMatch: NSTextCheckingResult?
        expression.enumerateMatches(in: attributedString.string, range: NSMakeRange(0, totoalLength)) { match, _, _ in
            if let match = match {
                if let rawStringBetweenMatch = rawStringBetweenMatch(lastMatch: lastMatch, currentMatch: match) {
                    block(.rawString(rawStringBetweenMatch))
                }
                
                block(.match(match))
                lastMatch = match
            }
        }
        
        if let resetString = resetString(lastMatch: lastMatch) {
            block(.rawString(resetString))
        }
    }
    
    func stringTotoalLength() -> Int {
        return attributedString.string.utf16.count
    }
    
    func rawStringBetweenMatch(lastMatch: NSTextCheckingResult?, currentMatch: NSTextCheckingResult) -> NSAttributedString? {
        let lastMatchEnd = lastMatch?.range.upperBound ?? 0
        let currentMatchStart = currentMatch.range.lowerBound
        guard currentMatchStart > lastMatchEnd else {
            return nil
        }
        
        return attributedString.attributedSubstring(from: NSMakeRange(lastMatchEnd, (currentMatchStart - lastMatchEnd)))
    }
    
    func resetString(lastMatch: NSTextCheckingResult?) -> NSAttributedString? {
        guard let lastMatch = lastMatch else {
            return attributedString.attributedSubstring(from: NSMakeRange(0, totoalLength))
        }
        
        let currentIndex = lastMatch.range.upperBound
        if totoalLength > currentIndex {
            return attributedString.attributedSubstring(from: NSMakeRange(currentIndex, (totoalLength - currentIndex)))
        } else {
            return nil
        }
    }
}
