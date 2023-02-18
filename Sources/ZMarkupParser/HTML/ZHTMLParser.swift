//
//  ZHTMLParser.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public struct ZHTMLParser: ZMarkupParser {
    let htmlTags: [HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    let rootStyle: MarkupStyle
    
    public var linkTextAttributes: [NSAttributedString.Key: Any] {
        let style = self.htmlTags.first(where: { $0.tagName.isEqualTo(WC3HTMLTagName.a.rawValue) })?.customStyle ?? MarkupStyle.link
        return style.render()
    }

    public func selector(_ string: String) -> HTMLSelector {
        return self.selector(NSAttributedString(string: string))
    }
    
    public func selector(_ attributedString: NSAttributedString) -> HTMLSelector {
        let rootSelector = process(attributedString)
        return rootSelector
    }
    
    public func render(_ string: String) -> NSAttributedString {
        return self.render(NSAttributedString(string: string))
    }
    
    public func render(_ attributedString: NSAttributedString) -> NSAttributedString {
        let rootSelector = process(attributedString)
        let rootMarkup = RootHTMLSelectorToRootMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes).process(from: rootSelector)
        let attributedString = RootMarkupRenderProcessor().process(from: rootMarkup)
        
        return attributedString
    }
    
    public func stripper(_ string: String) -> String {
        return self.stripper(NSAttributedString(string: string)).string
    }
    
    public func stripper(_ attributedString: NSAttributedString) -> NSAttributedString {
        let rootSelector = process(attributedString)
        let rootMarkup = RootHTMLSelectorToRootMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes).process(from: rootSelector)
        let attributedString = RootMarkupStripperProcessor().process(from: rootMarkup)
        
        return attributedString
    }
    
    private func process(_ attributedString: NSAttributedString) -> RootHTMLSelecor {
        let parsedResult = HTMLStringToParsedResultProcessor().process(from: attributedString)
        let formatedParsedResult = HTMLParsedResultFormatterProcessor().process(from: parsedResult)
        let rootSelector = HTMLParsedResultToRootHTMLSelectorProcessor().process(from: formatedParsedResult)
        
        return rootSelector
    }
}
