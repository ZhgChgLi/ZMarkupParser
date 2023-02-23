//
//  HTMLParsedResultFormatterProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class HTMLParsedResultFormatterProcessor: ParserProcessor {
    typealias From = [HTMLParsedResult]
    typealias To = From
    
    
    func process(from: From) -> To {
        var newItems = from
        
        var stackExpectedStartItems: [HTMLParsedResult.StartItem] = []
        var itemIndex = 0
        while itemIndex < newItems.count {
            switch newItems[itemIndex] {
            case .start(let item):
                if item.isIsolated {
                    if WC3HTMLTagName(rawValue: item.tagName) == nil && (item.attributes?.isEmpty ?? true) {
                        newItems[itemIndex] = .rawString(item.tagAttributedString)
                    } else {
                        newItems[itemIndex] = .selfClosing(item.convertToSelfClosingParsedItem())
                    }
                    itemIndex += 1
                } else {
                    stackExpectedStartItems.append(item)
                    itemIndex += 1
                }
            case .close(let item):
                let reversedStackExpectedStartItems = Array(stackExpectedStartItems.reversed())
                guard let reversedStackExpectedStartItemsOccurredIndex = reversedStackExpectedStartItems.firstIndex(where: { $0.tagName == item.tagName }) else {
                    itemIndex += 1
                    continue
                }
                
                let reversedStackExpectedStartItemsOccurred = Array(reversedStackExpectedStartItems.prefix(upTo: reversedStackExpectedStartItemsOccurredIndex))
                
                guard reversedStackExpectedStartItemsOccurred.count != 0 else {
                    // is pair, pop
                    stackExpectedStartItems.removeLast()
                    itemIndex += 1
                    continue
                }
                
                // not pair, may wrong format, e.g. cc<a>te<b>ss<c>sas</b>fat</a>essv</c>
                let stackExpectedStartItemsOccurred = Array(reversedStackExpectedStartItemsOccurred.reversed())
                let afterItems = stackExpectedStartItemsOccurred.map({ HTMLParsedResult.start($0) })
                let beforeItems = reversedStackExpectedStartItemsOccurred.map({ HTMLParsedResult.close($0.convertToCloseParsedItem()) })
                newItems.insert(contentsOf: afterItems, at: newItems.index(after: itemIndex))
                newItems.insert(contentsOf: beforeItems, at: itemIndex)
                
                itemIndex = newItems.index(after: itemIndex) + stackExpectedStartItemsOccurred.count
                
                stackExpectedStartItems.removeAll { startItem in
                    return reversedStackExpectedStartItems.prefix(through: reversedStackExpectedStartItemsOccurredIndex).contains(where: { $0 === startItem })
                }
            case .selfClosing, .rawString:
                itemIndex += 1
            }
        }
        
        return newItems
    }
}
