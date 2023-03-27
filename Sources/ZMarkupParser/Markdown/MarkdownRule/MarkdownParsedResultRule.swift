//
//  MarkdownParsedResultRule.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

protocol MarkdownParsedResultRule: AnyObject {
    func ranges(of presenters: [MarkdownParsedResult]) -> [NSRange]
    func handle(in presenters: inout [MarkdownParsedResult]) -> Markup?
}

class BoldItalicMarkdownParsedResultRule: MarkdownParsedResultRule {
    func ranges(of presenters: [MarkdownParsedResult]) -> [NSRange] {
        var ranges:[NSRange] = []
        var index = 0
        whileLoop: while index < presenters.count {
            var range: (Int?, Int?) = (nil, nil)
            for (offset, presenter) in Array(presenters[index...]).enumerated() {
                if case .symbol(.asterisk, _) = presenter {
                    if let startIndex = range.0,
                       let length = range.1,
                       startIndex + length > offset
                    {
                        ranges.append(NSMakeRange(startIndex + index, offset + 1))
                        index = startIndex + index + offset + 1
                        continue whileLoop
                    } else {
                        range.0 = offset
                        range.1 = 1
                    }
                }
            }
        }
        
        return ranges
    }
    
    func handle(in presenters: inout [MarkdownParsedResult]) -> Markup? {
        guard case let .symbol(.asterisk, startLength) = presenters.first else {
            return nil
        }
        guard case let .symbol(.asterisk, lastLength) = presenters.last else {
            return nil
        }
        
        let styleLength: Int
        if lastLength - startLength < 0 {
            // **** ***
            presenters.removeLast()
            presenters[0] = .symbol(.asterisk, startLength - lastLength)
            styleLength = lastLength
        } else if lastLength - startLength > 0 {
            // *** ****
            presenters.removeFirst()
            presenters[presenters.endIndex - 1] = .symbol(.asterisk, lastLength - startLength)
            styleLength = startLength
        } else {
            // *** ***
            presenters.removeFirst()
            presenters.removeLast()
            styleLength = startLength
        }
        
        if styleLength % 2 == 0 {
            // Bold
        } else {
            if styleLength == 1 {
                // Italic
            } else {
                // Bold+Italic
            }
        }
        
        return nil
    }
}

class LinkMarkdownParsedResultRule: MarkdownParsedResultRule {
    
    // https://pinkoi.com (
    // any text....
    // )
    func ranges(of presenters: [MarkdownParsedResult]) -> [NSRange] {
        var ranges:[NSRange] = []
        var index = 0
        whileLoop: while index < presenters.count {
            var range: (Int?, Int?) = (nil, nil)
            for (offset, presenter) in Array(presenters[index...]).enumerated() {
                if case .url = presenter {
                    range.0 = offset
                    range.1 = 1
                } else if case .symbol(.space, _) = presenter {
                    if let startIndex = range.0,
                       let length = range.1,
                       startIndex + length == offset
                    {
                        range.1 = length + 1
                    }
                } else if case .symbol(.leftParenthesis, _) = presenter {
                    if let startIndex = range.0,
                       let length = range.1,
                       startIndex + length == offset
                    {
                        range.1 = length + 1
                    }
                } else if case .symbol(.rightParenthesis, _) = presenter {
                    if let startIndex = range.0,
                       let length = range.1,
                       length == 3
                    {
                        ranges.append(NSMakeRange(startIndex + index, offset + 1))
                        index = startIndex + index + offset + 1
                        continue whileLoop
                    }
                }
            }
        }
        
        return ranges
    }
    
    func handle(in presenters: inout [MarkdownParsedResult]) -> Markup? {
        guard case let .url(url) = presenters.first else {
            return nil
        }
        presenters.removeFirst(3) // https://pinkoi.com (
        presenters.removeLast(1) // )
        
        return LinkMarkup()
    }
}

