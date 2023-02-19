//
//  ZMarkdownParserBuilder.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public final class ZMarkdownParserBuilder {
    
    private(set) var markdowns: [Markdown] = []
    private(set) var rootStyle: MarkupStyle = MarkupStyle.default
    
    public init() {
        
    }
    
    public static func initWithDefault() -> Self {
        var builder = Self.init()
        for markdownSymbol in ZMarkdownParserBuilder.markdownSymbols {
            builder = builder.add(markdownSymbol)
        }
        return builder
    }
    
    public func set(_ markdownSymbol: MarkdownSymbol, withCustomStyle markupStyle: MarkupStyle? = nil) -> Self {
        return self.add(markdownSymbol, withCustomStyle: markupStyle)
    }
    
    public func add(_ markdownSymbol: MarkdownSymbol, withCustomStyle markupStyle: MarkupStyle? = nil) -> Self {
        markdowns.removeAll { markdown in
            return markdown.symbol.regexString == markdownSymbol.regexString
        }
        
        markdowns.append(Markdown(symbol: markdownSymbol, customStyle: markupStyle))
        
        return self
    }
    
    public func set(rootStyle: MarkupStyle) -> Self {
        self.rootStyle = rootStyle
        return self
    }
    
    public func build() -> ZMarkdownParser {
        return ZMarkdownParser(markdowns: markdowns, rootStyle: rootStyle)
    }
}
