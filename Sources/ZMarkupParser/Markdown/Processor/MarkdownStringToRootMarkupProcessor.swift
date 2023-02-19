//
//  MarkdownStringToRootMarkupProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class MarkdownStringToRootMarkupProcessor: ParserProcessor {
    typealias From = NSAttributedString
    typealias To = RootMarkup
    
    let markdowns: [Markdown]
    let rootStyle: MarkupStyle
    
    private lazy var markdownsWithIdentifier: [String: Markdown] = {
        var patterns: [String: Markdown] = [:]
        for (index, markdown) in markdowns.enumerated() {
            patterns["markdownSymbol\(String(index))"] = markdown
        }
        return patterns
    }()
    
    private lazy var pattern: String = {
        var patterns: [String] = []
        for (identifier, markdown) in self.markdownsWithIdentifier {
            patterns.append("(?<\(identifier)>\(markdown.symbol.regexString))")
        }
        return patterns.joined(separator: "|")
    }()
    
    init(markdowns: [Markdown], rootStyle: MarkupStyle) {
        self.markdowns = markdowns
        self.rootStyle = rootStyle
    }
    
    func process(from: From) -> To {
        let rootMarkup = RootMarkup(style: rootStyle)
        var currentMarkup: Markup = rootMarkup
        walk(from: from, currentMarkup: &currentMarkup)
        return rootMarkup
    }
    
    func walk(from: From, currentMarkup: inout Markup) {
        guard let regxr = ParserRegexr(attributedString: from, pattern: pattern) else {
            return
        }
        
        regxr.enumerateMatches(using: { match in
            switch match {
            case .rawString(let rawStringAttributedString):
                currentMarkup.appendChild(markup: RawStringMarkup(attributedString: rawStringAttributedString))
            case .match(let matchResult):
                if let matchAttributedString = matchResult.attributedString(from, with: matchResult.range) {
                    if let matchMarkdown = markdownsWithIdentifier.first(where: { matchResult.range(withName: $0.key).location != NSNotFound })?.value {
                        
                        let markupStyleVisitor = MarkdownSymbolToMarkupStyleVisitor(attributedString: from, matchResult: matchResult)
                        var markupStyle: MarkupStyle?
                        if var style = markupStyleVisitor.visit(symbol: matchMarkdown.symbol) {
                            style.fillIfNil(from: matchMarkdown.customStyle)
                            markupStyle = style
                        } else {
                            markupStyle = matchMarkdown.customStyle
                        }
                        
                        let markupVisitor = MarkdownSymbolToMarkupVisitor(style: markupStyle)
                        let markup = markupVisitor.visit(symbol: matchMarkdown.symbol)
                        
                        let contentVisitor = MarkdownSymbolRegexContentVisitor(attributedString: from, matchResult: matchResult)
                        if let content = contentVisitor.visit(symbol: matchMarkdown.symbol) {
                            let oldCurrentMarkup = currentMarkup
                            oldCurrentMarkup.appendChild(markup: markup)
                            currentMarkup = markup
                            
                            if content == from {
                                currentMarkup.appendChild(markup: markup)
                            } else {
                                walk(from: content, currentMarkup: &currentMarkup)
                            }
                            currentMarkup = oldCurrentMarkup
                        } else {
                            currentMarkup.appendChild(markup: markup)
                        }
                    } else {
                        currentMarkup.appendChild(markup: RawStringMarkup(attributedString: matchAttributedString))
                    }
                }
            }
        })
    }
}
