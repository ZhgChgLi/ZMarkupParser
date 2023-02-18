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
            walk(newItems[itemIndex], newItems: &newItems, itemIndex: &itemIndex, stackExpectedStartItems: &stackExpectedStartItems)
        }
        
        // has reset stack
        // isolated start,
        // remove all placeholder item and treat first occurred as rawString
        for stackExpectedStartItem in stackExpectedStartItems {
            guard let firstIndex = newItems.firstIndex(where: { result in
                if case let HTMLParsedResult.start(item) = result {
                    return item.token == stackExpectedStartItem.token
                } else {
                    return false
                }
            }) else {
                continue
            }
            
            guard case let HTMLParsedResult.start(first) = newItems[firstIndex] else {
                continue
            }
            
            newItems[firstIndex] = .isolatedStart(first)
            newItems.removeAll { result in
                switch result {
                case .placeholderStart(let item):
                    return item.token == first.token
                case .placeholderClose(let item):
                    return item.token == first.token
                default:
                    return false
                }
            }
        }
        
        return newItems
    }
    
    func walk(_ thisItem: HTMLParsedResult, newItems: inout [HTMLParsedResult], itemIndex: inout Int, stackExpectedStartItems: inout [HTMLParsedResult.StartItem]) {
        
        switch thisItem {
        case .start(let item), .placeholderStart(let item):
            stackExpectedStartItems.append(item)
            itemIndex += 1
        case .close(let item), .placeholderClose(let item):
            let reversedStackExpectedStartItems = Array(stackExpectedStartItems.reversed())
            guard let reversedStackExpectedStartItemsOccurredIndex = reversedStackExpectedStartItems.firstIndex(where: { $0.tagName == item.tagName }) else {
                // isolated end
                // treat as isolated end
                newItems[itemIndex] = .isolatedClose(item)
                itemIndex += 1
                return
            }
            
            let reversedStackExpectedStartItemsOccurred = Array(reversedStackExpectedStartItems.prefix(upTo: reversedStackExpectedStartItemsOccurredIndex))
            
            guard reversedStackExpectedStartItemsOccurred.count != 0 else {
                // is pair, pop
                stackExpectedStartItems.removeLast()
                itemIndex += 1
                return
            }
            
            // not pair, may wrong format, e.g. cc<a>te<b>ss<c>sas</b>fat</a>essv</c>
            let stackExpectedStartItemsOccurred = Array(reversedStackExpectedStartItemsOccurred.reversed())
            let afterItems = stackExpectedStartItemsOccurred.map({ HTMLParsedResult.placeholderStart($0) })
            let beforeItems = reversedStackExpectedStartItemsOccurred.map({ HTMLParsedResult.placeholderClose($0.convertToCloseParsedItem()) })
            newItems.insert(contentsOf: afterItems, at: newItems.index(after: itemIndex))
            newItems.insert(contentsOf: beforeItems, at: itemIndex)
            
            itemIndex = newItems.index(after: itemIndex) + stackExpectedStartItemsOccurred.count
            
            stackExpectedStartItems.removeAll { startItem in
                return reversedStackExpectedStartItems.prefix(through: reversedStackExpectedStartItemsOccurredIndex).contains(where: { $0.token == startItem.token })
            }
        case .selfClosing, .rawString, .isolatedStart, .isolatedClose:
            itemIndex += 1
        }
    }
}
