//
//  HTMLParsedResultToRootHTMLSelectorProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

final class HTMLParsedResultToRootHTMLSelectorProcessor: ParserProcessor {
    typealias From = [HTMLParsedResult]
    typealias To = RootHTMLSelecor
        
    func process(from: From) -> To {
        let rootSelector = RootHTMLSelecor()
        var currentSelector: HTMLSelector = rootSelector
        var stackExpectedStartItems: [HTMLParsedResult.StartItem] = []
        
        for item in from {
            walk(item, currentSelector: &currentSelector, stackExpectedStartItems: &stackExpectedStartItems)
        }
        return rootSelector
    }
    
    func walk(_ thisItem: HTMLParsedResult, currentSelector: inout HTMLSelector, stackExpectedStartItems: inout [HTMLParsedResult.StartItem]) {
        switch thisItem {
        case .start(let item), .placeholderStart(let item):
            let selector = HTMLTagSelecor(tagName: item.tagName, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
            currentSelector.appendChild(selector: selector)
            currentSelector = selector
            
            stackExpectedStartItems.append(item)
        case .selfClosing(let item):
            let selector = HTMLTagSelecor(tagName: item.tagName, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
            currentSelector.appendChild(selector: selector)
        case .close(let item), .placeholderClose(let item):
            if let lastTagName = stackExpectedStartItems.popLast()?.tagName,
               lastTagName == item.tagName {
                currentSelector = currentSelector.parent ?? currentSelector
            }
        case .rawString(let attributedString):
            currentSelector.appendChild(selector: HTMLTagContentSelecor(attributedString: attributedString))
        case .isolatedStart(let item):
            if WC3HTMLTagName(rawValue: item.tagName) == nil && (item.attributes?.isEmpty ?? true) {
                // not a potential html tag
                currentSelector.appendChild(selector: HTMLTagContentSelecor(attributedString: item.tagAttributedString))
            } else {
                let selector = HTMLTagSelecor(tagName: item.tagName, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
                currentSelector.appendChild(selector: selector)
            }
        case .isolatedClose:
            break
        }
    }
}
