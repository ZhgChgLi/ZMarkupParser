//
//  RootHTMLSelectorToRootMarkupProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

final class RootHTMLSelectorToRootMarkupProcessor: ParserProcessor {
    typealias From = RootHTMLSelecor
    typealias To = RootMarkup
    
    let rootStyle: MarkupStyle
    let htmlTags: [HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    init(rootStyle: MarkupStyle, htmlTags: [HTMLTag], styleAttributes: [HTMLTagStyleAttribute]) {
        self.rootStyle = rootStyle
        self.htmlTags = htmlTags
        self.styleAttributes = styleAttributes
    }
    
    func process(from: From) -> To {
        let rootMarkup = RootMarkup(style: rootStyle)
        
        for childMarkup in from.childSelectors.compactMap({ walk($0) }) {
            rootMarkup.appendChild(markup: childMarkup)
        }
        
        return rootMarkup
    }
    
    func walk(_ selector: HTMLSelector) -> Markup? {
        let markup: Markup
        switch selector {
        case let content as HTMLTagContentSelecor:
            markup = RawStringMarkup(attributedString: content.attributedString)
        case let tag as HTMLTagSelecor:
            let htmlTagName = self.htmlTags.first(where: { $0.tagName.isEqualTo(tag.tagName) })?.tagName ?? ExtendTagName(tag.tagName)
            markup = makeMarkup(tagName: htmlTagName, tagAttributedString: tag.tagAttributedString, attributes: tag.attributes)
        default:
            return nil
        }
        
        for childMarkup in selector.childSelectors.compactMap({ walk($0) }) {
            markup.appendChild(markup: childMarkup)
        }
        
        return markup
    }
    
    func makeMarkup(tagName: HTMLTagName, tagAttributedString: NSAttributedString, attributes: [String: String]?) -> Markup {
        let customStyle = htmlTags.first(where: { $0.tagName.isEqualTo(tagName.string) })?.customStyle
        let markupStyleVisitor = HTMLTagNameToMarkupStyleVisitor(customStyle: customStyle, attributes: attributes, styleAttributes: self.styleAttributes)
        let style = markupStyleVisitor.visit(tagName: tagName)
        
        let markupVisitor = HTMLTagNameToMarkupVisitor(tagAttributedString: tagAttributedString, attributes: attributes, with: style)
        let markup = markupVisitor.visit(tagName: tagName)
        return markup
    }
}
