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
    
    let htmlTags: [String: HTMLTag]

    init(htmlTags: [HTMLTag]) {
        self.htmlTags = Dictionary(uniqueKeysWithValues: htmlTags.map { ($0.tagName.string, $0) })
    }
        
    func process(from: From) -> To {
        var htmlElementComponents: [HTMLElementMarkupComponent] = []
        let rootMarkup = RootMarkup()
        var currentMarkup: Markup = rootMarkup
        var stackExpectedStartItems: [HTMLParsedResult.StartItem] = []
        for thisItem in from {
            switch thisItem {
            case .start(let item):
                let visitor = HTMLTagNameToMarkupVisitor(attributes: item.attributes, isSelfClosingTag: false)
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = visitor.visit(tagName: htmlTag.tagName)
                let componentElement = HTMLElementMarkupComponent.HTMLElement(
                    tag: htmlTag,
                    tagAttributedString: item.tagAttributedString,
                    attributes: item.attributes
                )
                let markupComponent = HTMLElementMarkupComponent(
                    markup: markup,
                    value: componentElement
                )
                htmlElementComponents.append(markupComponent)
                currentMarkup.appendChild(markup: markup)
                currentMarkup = markup
                
                stackExpectedStartItems.append(item)
            case .selfClosing(let item):
                let visitor = HTMLTagNameToMarkupVisitor(attributes: item.attributes, isSelfClosingTag: true)
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = visitor.visit(tagName: htmlTag.tagName)
                let componentElement = HTMLElementMarkupComponent.HTMLElement(
                    tag: htmlTag,
                    tagAttributedString: item.tagAttributedString,
                    attributes: item.attributes
                )
                let markupComponent = HTMLElementMarkupComponent(
                    markup: markup,
                    value: componentElement
                )
                htmlElementComponents.append(markupComponent)
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
        return To(markup: rootMarkup, htmlElementComponents: htmlElementComponents)
    }
}
