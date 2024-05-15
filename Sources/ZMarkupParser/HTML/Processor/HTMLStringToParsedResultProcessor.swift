//
//  HTMLStringToParsedResultProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/9.
//

import Foundation

struct HTMLStringToParsedResultProcessorResult {
    let needFormatter: Bool
    let items: [HTMLParsedResult]
}

final class HTMLStringToParsedResultProcessor: ParserProcessor {
    typealias From = NSAttributedString
    typealias To = (HTMLStringToParsedResultProcessorResult)
    
    // e.g 1. <br rel="test"/>
    // tagName = br
    // tagAttributes = rel="test"
    // selfClosingTag = /
    // e.g 2. <span style="color:#ff00ff;">
    // tagName = span
    // tagAttributes = style="color:#ff00ff;"
    // e.g 3. </span>
    // selfClosingTag = /
    // tagName = span
    static let htmlTagRegexPattern: String = #"<(?:(?<closeTag>\/)?(?<tagName>[A-Za-z0-9]+)(?<tagAttributes>(?:\s*([\w\-]+)\s*=\s*(["|']).*?\5)*)\s*(?<selfClosingTag>\/)?>)"#
    
    // e.g. href="https://zhgchg.li"
    // name = href
    // value = https://zhgchg.li
    static let htmlTagAttributesRegexPattern: String = #"\s*(?<name>(?:[\w\-]+))\s*={1}\s*(["|']){1}(?<value>.*?)\2\s*"#
    
    // will match:
    // <!--Test--> / <\!DOCTYPE html> / ` \n `
    static let htmlCommentOrDocumentHeaderRegexPattern: String = #"(\<\!\-\-(?:.*)\-\-\>)|(\<\!DOCTYPE(?:[^>]*)\>)|(\<\!doctype(?:[^>]*)\>)|(\s*\n\s*$)|(^\s*\n\s*)"#
        
    func process(from: From) -> To {
        var items: [HTMLParsedResult] = []
        guard let regxr = ParserRegexr(attributedString: from, pattern: Self.htmlTagRegexPattern) else {
            return HTMLStringToParsedResultProcessorResult(needFormatter: false, items: items)
        }
        
        var stackStartItems: [HTMLParsedResult.StartItem] = []
        var needForamatter: Bool = false
        
        regxr.enumerateMatches(using: { match in
            switch match {
            case .rawString(let rawStringAttributedString):
                let commentAndDocumentHeaderRegxer = ParserRegexr(attributedString: rawStringAttributedString, pattern: Self.htmlCommentOrDocumentHeaderRegexPattern)
                commentAndDocumentHeaderRegxer?.enumerateMatches(using: { commentAndDocumentHeaderMatch in
                    switch commentAndDocumentHeaderMatch {
                    case .match:
                        // match <!--HTML Comment--> or <!DOCTYPE html> or ` \n `
                        // ignore it
                        break
                    case .rawString(let stringAttributedString):
                        items.append(.rawString(stringAttributedString))
                    }
                })
            case .match(let matchResult):
                let matchAttributedString = matchResult.attributedString(from, with: matchResult.range)
                let matchTag = matchResult.attributedString(from, with: "tagName")?.string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let matchIsEndTag = matchResult.attributedString(from, with: "closeTag")?.string.trimmingCharacters(in: .whitespacesAndNewlines) == "/"
                let matchTagAttributes = parseAttributes(matchResult.attributedString(from, with: "tagAttributes"))
                let matchIsSelfClosingTag = matchResult.attributedString(from, with: "selfClosingTag")?.string.trimmingCharacters(in: .whitespacesAndNewlines) == "/"
                if let matchAttributedString = matchAttributedString, let matchTag = matchTag {
                    if matchIsSelfClosingTag {
                        // <br/>
                        items.append(.selfClosing(.init(tagName: matchTag, tagAttributedString: matchAttributedString, attributes: matchTagAttributes)))
                    } else {
                        // <a> or </a>
                        if matchIsEndTag {
                            // </a>
                            if let index = stackStartItems.lastIndex(where: { $0.tagName == matchTag }) {
                                if index != stackStartItems.count - 1 {
                                    needForamatter = true
                                }
                                items.append(.close(.init(tagName: matchTag)))
                                stackStartItems.remove(at: index)
                            } else {
                                // isolated/reduntant close tag </a>
                            }
                        } else {
                            // <a>
                            let startItem: HTMLParsedResult.StartItem = HTMLParsedResult.StartItem(tagName: matchTag, tagAttributedString: matchAttributedString, attributes: matchTagAttributes)
                            items.append(.start(startItem))
                            stackStartItems.append(startItem)
                        }
                    }
                }
            }
        })
        
        for stackStartItem in stackStartItems {
            stackStartItem.isIsolated = true
            needForamatter = true
        }
        
        return HTMLStringToParsedResultProcessorResult(needFormatter: needForamatter, items: items)
    }

    
    func parseAttributes(_ attributedString: NSAttributedString?) -> [String: String]? {
        guard let attributedString = attributedString else { return nil }
        guard let regxr = ParserRegexr(attributedString: attributedString, pattern: Self.htmlTagAttributesRegexPattern) else {
            return nil
        }
        
        var attributes: [String: String] = [:]
        
        regxr.enumerateMatches { matchType in
            switch matchType {
            case .rawString:
                break
            case .match(let matchResult):
                if let key = matchResult.attributedString(attributedString, with: "name")?.string,
                   let value = matchResult.attributedString(attributedString, with: "value")?.string {
                    attributes[key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()] = value.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return (attributes.isEmpty) ? (nil) : (attributes)
    }
}
