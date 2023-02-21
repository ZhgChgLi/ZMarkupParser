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
        
        for thisItem in from {
            switch thisItem {
            case .start(let item):
                let selector = HTMLTagSelecor(tagName: item.tagName, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
                currentSelector.appendChild(selector: selector)
                currentSelector = selector
                
                stackExpectedStartItems.append(item)
            case .selfClosing(let item):
                let selector = HTMLTagSelecor(tagName: item.tagName, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
                currentSelector.appendChild(selector: selector)
            case .close(let item):
                if let lastTagName = stackExpectedStartItems.popLast()?.tagName,
                   lastTagName == item.tagName {
                    currentSelector = currentSelector.parent ?? currentSelector
                }
            case .rawString(let attributedString):
                currentSelector.appendChild(selector: HTMLTagContentSelecor(attributedString: attributedString))
            }
        }
        return rootSelector
    }
}
