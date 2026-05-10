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
    //
    // Branches in order:
    //   1. HTML comment            <!-- ... -->
    //   2. HTML DOCTYPE             <!DOCTYPE ...>  / <!doctype ...>
    //   3. HTML tag (named groups)  <tag>, </tag>, <tag/>
    // For comment / DOCTYPE matches the `tagName` named group will not participate, so the
    // enumeration loop drops them by checking `range(withName: "tagName").location == NSNotFound`.
    static let htmlTagRegexPattern: String = #"(?:\<\!\-\-(?:.*?)\-\-\>)|(?:\<\!DOCTYPE(?:[^>]*)\>)|(?:\<\!doctype(?:[^>]*)\>)|<(?:(?<closeTag>\/)?(?<tagName>[A-Za-z0-9]+)(?<tagAttributes>(?:\s*([\w\-]+)\s*=\s*(["|']).*?\5)*)\s*(?<selfClosingTag>\/)?>)"#

    // e.g. href="https://zhgchg.li"
    // name = href
    // value = https://zhgchg.li
    static let htmlTagAttributesRegexPattern: String = #"\s*(?<name>(?:[\w\-]+))\s*={1}\s*(["|']){1}(?<value>.*?)\2\s*"#

    // Matches purely whitespace lines that surround tag / comment matches; used to trim leading
    // and trailing whitespace+newline noise from the raw string between matches so that "indented"
    // HTML does not leak indentation into the rendered output.
    static let htmlCommentOrDocumentHeaderRegexPattern: String = #"(\s*\n\s*$)|(^\s*\n\s*)"#

    func process(from: From) -> To {
        let source = from.string
        let scanResult = HTMLScanner.scan(source)

        var items: [HTMLParsedResult] = []
        items.reserveCapacity(scanResult.tokens.count)

        for token in scanResult.tokens {
            switch token {
            case .text(let range):
                let nsRange = NSRange(range, in: source)
                items.append(.rawString(from.attributedSubstring(from: nsRange)))
            case .start(let open):
                let nsRange = NSRange(open.rawRange, in: source)
                let startItem = HTMLParsedResult.StartItem(
                    tagName: open.nameLower,
                    tagAttributedString: from.attributedSubstring(from: nsRange),
                    attributes: parseAttributes(for: open, in: source)
                )
                startItem.isIsolated = open.isIsolated
                items.append(.start(startItem))
            case .close(let close):
                items.append(.close(.init(tagName: close.nameLower)))
            case .selfClose(let open):
                let nsRange = NSRange(open.rawRange, in: source)
                items.append(.selfClosing(.init(
                    tagName: open.nameLower,
                    tagAttributedString: from.attributedSubstring(from: nsRange),
                    attributes: parseAttributes(for: open, in: source)
                )))
            }
        }

        return HTMLStringToParsedResultProcessorResult(needFormatter: scanResult.needFormatter, items: items)
    }

    private func parseAttributes(for open: TagOpen, in source: String) -> [String: String]? {
        if let cached = open.parsedAttributes {
            return cached.isEmpty ? nil : cached
        }
        guard let attrsRange = open.attributesRange, !source[attrsRange].isEmpty else {
            return nil
        }
        let attrAttributedString = NSAttributedString(string: String(source[attrsRange]))
        let parsed = parseAttributes(attrAttributedString)
        open.parsedAttributes = parsed ?? [:]
        return parsed
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
