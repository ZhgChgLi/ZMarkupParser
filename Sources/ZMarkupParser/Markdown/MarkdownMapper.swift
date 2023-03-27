//
//  MarkdownParsedResultRule.swift
//  
//
//  Created by Harry Li on 2023/3/27.
//

import Foundation

enum MarkdownMapperRule {
    case matchLength(MarkdownSymbol, Int)
    case match(MarkdownSymbol)
    case url
    case rawString
    case any
    
    func isEqual(to: MarkdownParsedResult) -> Bool {
        switch (self, to) {
        case (.url, .url):
            return true
        case (.match(let leftSymbol), .symbol(let rightSymbol, _, _)):
            return leftSymbol == rightSymbol
        case (.matchLength(let leftSymbol, let leftLength), .symbol(let rightSymbol, let rightLength, _)):
            return leftSymbol == rightSymbol && leftLength == rightLength
        case (.rawString, .rawString):
            return true
        case (.any, _):
            return true
        default:
            return false
        }
    }
}

protocol MarkdownMapper: AnyObject {
    var rule: [MarkdownMapperRule] { get }
    func accept<V: MarkdownMapperVisitor>(_ visitor: V) -> V.Result
}

protocol MarkdownMapperVisitor {
    associatedtype Result
        
    func visit(mapper: MarkdownMapper) -> Result
}

extension MarkdownMapperVisitor {
    func visit(mapper: MarkdownMapper) -> Result {
        return mapper.accept(self)
    }
}

extension Array where Element == MarkdownParsedResult {
    func ranges(of rule: [MarkdownMapperRule]) -> [NSRange] {
        
        var ranges:[NSRange] = []
        var index = 0
        
        var range: (Int?, Int?) = (nil, nil)
        var stack = rule
        var isInAny = false
        
        whileLoop: while index < self.count {
            let item = self[index]
            
            if let firstRule = stack.first, firstRule.isEqual(to: item) {
                let startIndex = range.0 ?? index
                let length = range.1 ?? 0
                if startIndex + length == index {
                    // match
                    range.0 = startIndex
                    range.1 = length + 1
                    
                    if isInAny {
                        stack.removeFirst()
                        if stack.first?.isEqual(to: item) ?? false {
                            isInAny = false
                            stack.removeFirst()
                        } else if index < self.count - 1 {
                            stack.insert(.any, at: 0)
                        }
                    } else {
                        if case .any = firstRule {
                            // is any...
                            isInAny = true
                        } else {
                            stack.removeFirst()
                        }
                    }
                    
                    if stack.isEmpty {
                        ranges.append(NSMakeRange(startIndex, length + 1))
                        index = startIndex + length + 1
                        
                        // reset for next
                        stack = rule
                        range = (nil, nil)
                        isInAny = false
                        
                        continue
                    }
                }
            }
            
            index += 1
        }
        
        return ranges
    }
}
