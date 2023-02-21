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
    
    static let dispatchQueue: DispatchQueue = DispatchQueue(label: "ZHTMLParser.Queue", qos: .userInteractive)
    
    public var linkTextAttributes: [NSAttributedString.Key: Any] {
        var style = self.htmlTags.first(where: { $0.tagName.isEqualTo(WC3HTMLTagName.a.rawValue) })?.customStyle ?? MarkupStyle.link
        style.fillIfNil(from: rootStyle)
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
    
    //
    
    public func selector(_ string: String, completionHandler: @escaping (HTMLSelector) -> Void) {
        self.selector(NSAttributedString(string: string), completionHandler: completionHandler)
    }
    
    public func selector(_ attributedString: NSAttributedString, completionHandler: @escaping (HTMLSelector) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let rootSelector = process(attributedString)
            DispatchQueue.main.async {
                completionHandler(rootSelector)
            }
        }
    }
    
    public func render(_ string: String, completionHandler: @escaping (NSAttributedString) -> Void) {
        self.render(NSAttributedString(string: string), completionHandler: completionHandler)
    }
    
    public func render(_ attributedString: NSAttributedString, completionHandler: @escaping (NSAttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let rootSelector = process(attributedString)
            let rootMarkup = RootHTMLSelectorToRootMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes).process(from: rootSelector)
            let result = RootMarkupRenderProcessor().process(from: rootMarkup)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
    
    public func stripper(_ string: String, completionHandler: @escaping (String) -> Void) {
        self.stripper(NSAttributedString(string: string)) { attributedString in
            completionHandler(attributedString.string)
        }
    }
    
    public func stripper(_ attributedString: NSAttributedString, completionHandler: @escaping (NSAttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let rootSelector = process(attributedString)
            let rootMarkup = RootHTMLSelectorToRootMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes).process(from: rootSelector)
            let attributedString = RootMarkupStripperProcessor().process(from: rootMarkup)
            DispatchQueue.main.async {
                completionHandler(attributedString)
            }
        }
    }
}

private extension ZHTMLParser {
    func process(_ attributedString: NSAttributedString) -> RootHTMLSelecor {
        let parsedResult = HTMLStringToParsedResultProcessor().process(from: attributedString)
        var items = parsedResult.items
        if parsedResult.needFormatter {
            items = HTMLParsedResultFormatterProcessor().process(from: items)
        }
        let rootSelector = HTMLParsedResultToRootHTMLSelectorProcessor().process(from: items)
        
        return rootSelector
    }
}
