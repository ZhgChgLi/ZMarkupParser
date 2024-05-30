//
//  ZHTMLParser.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public final class ZHTMLParser {
    let htmlTags: [HTMLTag]
    let styleAttributes: [HTMLTagStyleAttribute]
    let rootStyle: MarkupStyle?
    
    let htmlParsedResultToHTMLElementWithRootMarkupProcessor: HTMLParsedResultToHTMLElementWithRootMarkupProcessor
    let htmlElementWithMarkupToMarkupStyleProcessor: HTMLElementWithMarkupToMarkupStyleProcessor
    let markupRenderProcessor: MarkupRenderProcessor
    
    lazy var htmlParsedResultFormatter: HTMLParsedResultFormatterProcessor = HTMLParsedResultFormatterProcessor()
    lazy var htmlStringToParsedResult: HTMLStringToParsedResultProcessor = HTMLStringToParsedResultProcessor()
    lazy var markupStripperProcessor: MarkupStripperProcessor = MarkupStripperProcessor()
    
    init(
        htmlTags: [HTMLTag],
        styleAttributes: [HTMLTagStyleAttribute],
        policy: MarkupStylePolicy,
        rootStyle: MarkupStyle?
    ) {
        self.htmlTags = htmlTags
        self.styleAttributes = styleAttributes
        self.rootStyle = rootStyle
        
        self.markupRenderProcessor = MarkupRenderProcessor(rootStyle: rootStyle)
        
        self.htmlParsedResultToHTMLElementWithRootMarkupProcessor = HTMLParsedResultToHTMLElementWithRootMarkupProcessor(htmlTags: htmlTags)
        self.htmlElementWithMarkupToMarkupStyleProcessor = HTMLElementWithMarkupToMarkupStyleProcessor(styleAttributes: styleAttributes, policy: policy, rootStyle: rootStyle)
    }
    
    static let dispatchQueue: DispatchQueue = DispatchQueue(label: "ZHTMLParser.Queue")
    
    public var linkTextAttributes: [NSAttributedString.Key: Any] {
        var style = self.htmlTags.first(where: { $0.tagName.isEqualTo(WC3HTMLTagName.a.rawValue) })?.customStyle ?? MarkupStyle.link
        style.fillIfNil(from: rootStyle)
        return style.render()
    }
    
    public func decodeHTMLEntities(_ string: String) -> String {
        return string.removingHTMLEntities()
    }
    
    public func decodeHTMLEntities(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.enumerateAttributes(in: NSMakeRange(0, mutableAttributedString.string.utf16.count)) { attributes, range, _ in
            let cleanString = mutableAttributedString.attributedSubstring(from: range).string.removingHTMLEntities()
            mutableAttributedString.deleteCharacters(in: range)
            mutableAttributedString.insert(NSAttributedString(string: cleanString, attributes: attributes), at: range.location)
        }
        
        return mutableAttributedString
    }
    
    public func selector(_ string: String) -> HTMLSelector {
        return self.selector(NSAttributedString(string: string))
    }
    
    public func selector(_ attributedString: NSAttributedString) -> HTMLSelector {
        let items = process(attributedString)
        let reuslt = htmlParsedResultToHTMLElementWithRootMarkupProcessor.process(from: items)
        
        return HTMLSelector(markup: reuslt.markup, componets: reuslt.htmlElementComponents)
    }
    
    public func render(_ string: String, forceDecodeHTMLEntities: Bool = true) -> NSAttributedString {
        return self.render(NSAttributedString(string: string), forceDecodeHTMLEntities: forceDecodeHTMLEntities)
    }
    
    public func render(_ selector: HTMLSelector) -> NSAttributedString {
        let styleComponets = htmlElementWithMarkupToMarkupStyleProcessor.process(from: (selector.markup, selector.componets))
        return markupRenderProcessor.process(from: (selector.markup, styleComponets))
    }
    
    public func render(_ attributedString: NSAttributedString, forceDecodeHTMLEntities: Bool = true) -> NSAttributedString {
        var newAttributedString = attributedString
        if forceDecodeHTMLEntities {
            newAttributedString = decodeHTMLEntities(attributedString)
        }
        let items = process(newAttributedString)
        let reuslt = htmlParsedResultToHTMLElementWithRootMarkupProcessor.process(from: items)
        let styleComponets = htmlElementWithMarkupToMarkupStyleProcessor.process(from: (reuslt.markup, reuslt.htmlElementComponents))
        
        return markupRenderProcessor.process(from: (reuslt.markup, styleComponets))
    }
    
    public func stripper(_ string: String) -> String {
        return self.stripper(NSAttributedString(string: string)).string
    }
    
    public func stripper(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stripedAttributedString = decodeHTMLEntities(attributedString)
        let items = process(stripedAttributedString)
        let reuslt = htmlParsedResultToHTMLElementWithRootMarkupProcessor.process(from: items)
        let resultAttributedString = markupStripperProcessor.process(from: reuslt.markup)
        
        return resultAttributedString
    }
    
    //
    
    public func selector(_ string: String, completionHandler: @escaping (HTMLSelector) -> Void) {
        self.selector(NSAttributedString(string: string), completionHandler: completionHandler)
    }
    
    public func selector(_ attributedString: NSAttributedString, completionHandler: @escaping (HTMLSelector) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let selector = self.selector(attributedString)
            DispatchQueue.main.async {
                completionHandler(selector)
            }
        }
    }
    
    public func render(_ selector: HTMLSelector, completionHandler: @escaping (NSAttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let attributedString = self.render(selector)
            DispatchQueue.main.async {
                completionHandler(attributedString)
            }
        }
    }
    
    public func render(_ string: String, forceDecodeHTMLEntities: Bool = true, completionHandler: @escaping (NSAttributedString) -> Void) {
        self.render(NSAttributedString(string: string), forceDecodeHTMLEntities: forceDecodeHTMLEntities, completionHandler: completionHandler)
    }
    
    public func render(_ attributedString: NSAttributedString, forceDecodeHTMLEntities: Bool = true, completionHandler: @escaping (NSAttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let attributedString = self.render(attributedString, forceDecodeHTMLEntities: forceDecodeHTMLEntities)
            DispatchQueue.main.async {
                completionHandler(attributedString)
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
            let attributedString = self.stripper(attributedString)
            DispatchQueue.main.async {
                completionHandler(attributedString)
            }
        }
    }
}

private extension ZHTMLParser {
    func process(_ attributedString: NSAttributedString) -> [HTMLParsedResult] {
        let parsedResult = htmlStringToParsedResult.process(from: attributedString)
        var items = parsedResult.items
        if parsedResult.needFormatter {
            items = htmlParsedResultFormatter.process(from: items)
        }
        
        return items
    }
}
