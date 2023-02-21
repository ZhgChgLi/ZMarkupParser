//
//  ZHTMLParser.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public final class ZHTMLParser: ZMarkupParser {
    let htmlTags: [HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    let rootStyle: MarkupStyle
    
    let parsedResultToRootMarkup: HTMLParsedResultToRootMarkupProcessor
    let htmlSelectorToMarkup: HTMLSelectorToMarkupProcessor
    lazy var parsedResultToRootHTMLSelector: HTMLParsedResultToRootHTMLSelectorProcessor = HTMLParsedResultToRootHTMLSelectorProcessor()
    lazy var parsedResultFormatter: HTMLParsedResultFormatterProcessor = HTMLParsedResultFormatterProcessor()
    lazy var stringToParsedResult: HTMLStringToParsedResultProcessor = HTMLStringToParsedResultProcessor()
    lazy var rootMarkupStripper: MarkupStripperProcessor = MarkupStripperProcessor()
    lazy var rootMarkupRender: MarkupRenderProcessor = MarkupRenderProcessor()
    
    init(htmlTags: [HTMLTag], styleAttributes: [HTMLTagStyleAttribute], rootStyle: MarkupStyle) {
        self.htmlTags = htmlTags
        self.styleAttributes = styleAttributes
        self.rootStyle = rootStyle
        self.parsedResultToRootMarkup = HTMLParsedResultToRootMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes)
        self.htmlSelectorToMarkup = HTMLSelectorToMarkupProcessor(rootStyle: rootStyle, htmlTags: htmlTags, styleAttributes: styleAttributes)
    }
    
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
        let items = process(attributedString)
        let rootSelector = parsedResultToRootHTMLSelector.process(from: items)
        return rootSelector
    }
    
    public func render(_ string: String) -> NSAttributedString {
        return self.render(NSAttributedString(string: string))
    }
    
    public func render(_ selector: HTMLSelector) -> NSAttributedString {
        let markup = htmlSelectorToMarkup.process(from: selector)
        let attributedString = rootMarkupRender.process(from: markup)
        return attributedString
    }
    
    public func render(_ attributedString: NSAttributedString) -> NSAttributedString {
        let items = process(attributedString)
        let rootMarkup = parsedResultToRootMarkup.process(from: items)
        let attributedString = rootMarkupRender.process(from: rootMarkup)
        
        return attributedString
    }
    
    public func stripper(_ string: String) -> String {
        return self.stripper(NSAttributedString(string: string)).string
    }
    
    public func stripper(_ attributedString: NSAttributedString) -> NSAttributedString {
        let items = process(attributedString)
        let rootMarkup = parsedResultToRootMarkup.process(from: items)
        let attributedString = rootMarkupStripper.process(from: rootMarkup)
        
        return attributedString
    }
    
    //
    
    public func selector(_ string: String, completionHandler: @escaping (HTMLSelector) -> Void) {
        self.selector(NSAttributedString(string: string), completionHandler: completionHandler)
    }
    
    public func selector(_ attributedString: NSAttributedString, completionHandler: @escaping (HTMLSelector) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let items = self.process(attributedString)
            let rootSelector = self.parsedResultToRootHTMLSelector.process(from: items)
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
            let items = self.process(attributedString)
            let rootMarkup = self.parsedResultToRootMarkup.process(from: items)
            let result = self.rootMarkupRender.process(from: rootMarkup)
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
            let items = self.process(attributedString)
            let rootMarkup = self.parsedResultToRootMarkup.process(from: items)
            let attributedString = self.rootMarkupStripper.process(from: rootMarkup)
            DispatchQueue.main.async {
                completionHandler(attributedString)
            }
        }
    }
}

private extension ZHTMLParser {
    func process(_ attributedString: NSAttributedString) -> [HTMLParsedResult] {
        let parsedResult = stringToParsedResult.process(from: attributedString)
        var items = parsedResult.items
        if parsedResult.needFormatter {
            items = parsedResultFormatter.process(from: items)
        }
        
        return items
    }
}
