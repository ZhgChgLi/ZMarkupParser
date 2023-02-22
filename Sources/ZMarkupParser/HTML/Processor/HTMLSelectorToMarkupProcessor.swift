//
//  RootHTMLSelectorToRootMarkupProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

final class HTMLSelectorToMarkupProcessor: ParserProcessor {
    typealias From = HTMLSelector
    typealias To = Markup
    
    let rootStyle: MarkupStyle?
    let htmlTags: [String: HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    init(rootStyle: MarkupStyle?, htmlTags: [HTMLTag], styleAttributes: [HTMLTagStyleAttribute]) {
        self.rootStyle = rootStyle
        self.htmlTags = Dictionary(uniqueKeysWithValues: htmlTags.map{ ($0.tagName.string, $0) })
        self.styleAttributes = styleAttributes
    }
    
    func process(from: From) -> To {
        return walk(from)
    }
    
    func walk(_ selector: HTMLSelector) -> Markup {
        let markup: Markup
        switch selector {
        case let content as RawStringSelecor:
            markup = RawStringMarkup(attributedString: content.attributedString)
        case let tag as HTMLTagSelecor:
            let htmlTag = self.htmlTags[tag.tagName] ?? HTMLTag(tagName: ExtendTagName(tag.tagName))
            markup = makeMarkup(tag: htmlTag, tagAttributedString: tag.tagAttributedString, attributes: tag.attributes)
        case _ as RootHTMLSelecor:
            markup = RootMarkup(style: rootStyle)
        default:
            markup = RootMarkup(style: rootStyle)
        }
        
        for childMarkup in selector.childSelectors.compactMap({ walk($0) }) {
            markup.appendChild(markup: childMarkup)
        }
        
        return markup
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
