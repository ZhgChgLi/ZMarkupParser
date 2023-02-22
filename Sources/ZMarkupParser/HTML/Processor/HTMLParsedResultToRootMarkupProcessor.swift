//
//  HTMLParsedResultToRootMarkupProcessor.swift
//  
//
//  Created by Harry Li on 2023/2/21.
//

import Foundation

final class HTMLParsedResultToRootMarkupProcessor: ParserProcessor {
    typealias From = [HTMLParsedResult]
    typealias To = RootMarkup
    
    let rootStyle: MarkupStyle?
    let htmlTags: [String: HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    init(rootStyle: MarkupStyle?, htmlTags: [HTMLTag], styleAttributes: [HTMLTagStyleAttribute]) {
        self.rootStyle = rootStyle
        self.htmlTags = Dictionary(uniqueKeysWithValues: htmlTags.map{ ($0.tagName.string, $0) })
        self.styleAttributes = styleAttributes
    }
        
    func process(from: From) -> To {
        let rootMarkup = RootMarkup(style: rootStyle)
        var currentMarkup: Markup = rootMarkup
        var stackExpectedStartItems: [HTMLParsedResult.StartItem] = []
        
        for thisItem in from {
            switch thisItem {
            case .start(let item):
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = makeMarkup(tag: htmlTag, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
                currentMarkup.appendChild(markup: markup)
                currentMarkup = markup
                
                stackExpectedStartItems.append(item)
            case .selfClosing(let item):
                let htmlTag = self.htmlTags[item.tagName] ?? HTMLTag(tagName: ExtendTagName(item.tagName))
                let markup = makeMarkup(tag: htmlTag, tagAttributedString: item.tagAttributedString, attributes: item.attributes)
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
        return rootMarkup
    }
    
    func makeMarkup(tag: HTMLTag, tagAttributedString: NSAttributedString, attributes: [String: String]?) -> Markup {
        let customStyle = tag.customStyle
        let markupStyleVisitor = HTMLTagNameToMarkupStyleVisitor(customStyle: customStyle, attributes: attributes, styleAttributes: self.styleAttributes)
        let style = markupStyleVisitor.visit(tagName: tag.tagName)
        
        let markupVisitor = HTMLTagNameToMarkupVisitor(tagAttributedString: tagAttributedString, attributes: attributes, with: style)
        let markup = markupVisitor.visit(tagName: tag.tagName)
        return markup
    }

}
