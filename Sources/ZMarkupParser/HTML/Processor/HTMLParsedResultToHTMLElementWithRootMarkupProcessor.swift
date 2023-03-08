//
//  HTMLParsedResultToHTMLElementWithRootMarkupProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation

final class HTMLParsedResultToHTMLElementWithRootMarkupProcessor: ParserProcessor {
    
    struct Result {
        let markup: Markup
        let htmlElementComponents: [HTMLElementMarkupComponent]
    }
    
    typealias From = [HTMLParsedResult]
    typealias To = Result
    
    private lazy var visitor = HTMLTagNameToMarkupVisitor()
    
    let htmlTags: [String: HTMLTag]
    init(htmlTags: [HTMLTag]) {
        self.htmlTags = Dictionary(uniqueKeysWithValues: htmlTags.map{ ($0.tagName.string, $0) })
    }
        
    func process(from: From) -> To {
        var htmlElementComponents: [HTMLElementMarkupComponent] = []
        let rootMarkup = RootMarkup()
        var currentMarkup: Markup = rootMarkup
        var stackExpectedStartItems: [HTMLParsedResult.StartItem] = []
        for thisItem in from {
            switch thisItem {
            case .start(let item):
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = visitor.visit(tagName: htmlTag.tagName)
                htmlElementComponents.append(.init(markup: markup, value: .init(tag: htmlTag, tagAttributedString: item.tagAttributedString, attributes: item.attributes)))
                currentMarkup.appendChild(markup: markup)
                currentMarkup = markup
                
                stackExpectedStartItems.append(item)
            case .selfClosing(let item):
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = visitor.visit(tagName: htmlTag.tagName)
                htmlElementComponents.append(.init(markup: markup, value: .init(tag: htmlTag, tagAttributedString: item.tagAttributedString, attributes: item.attributes)))
                currentMarkup.appendChild(markup: markup)
            case .close(let item):
                if let lastTagName = stackExpectedStartItems.popLast()?.tagName,
                   lastTagName == item.tagName {
                    currentMarkup = currentMarkup.parentMarkup ?? currentMarkup
                }
            case .rawString(let attributedString):
                currentMarkup.appendChild(markup: RawStringMarkup(attributedString: attributedString))
            }
        }
        return .init(markup: rootMarkup, htmlElementComponents: htmlElementComponents)
    }
}
