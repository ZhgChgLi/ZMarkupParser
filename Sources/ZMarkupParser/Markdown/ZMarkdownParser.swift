//
//  ZMarkdownParser.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct ZMarkdownParser: ZMarkupParser {
    let markdowns: [Markdown]
    let rootStyle: MarkupStyle
    
    public func render(_ string: String) -> NSAttributedString {
        return self.render(NSAttributedString(string: string))
    }
    
    public func render(_ attributedString: NSAttributedString) -> NSAttributedString {
        let rootMarkup = process(attributedString)
        let renderProcessor = RootMarkupRenderProcessor()
        return renderProcessor.process(from: rootMarkup)
    }
    
    public func stripper(_ string: String) -> String {
        return self.stripper(NSAttributedString(string: string)).string
    }
    
    public func stripper(_ attributedString: NSAttributedString) -> NSAttributedString {
        let rootMarkup = process(attributedString)
        let stripperProcessor = RootMarkupStripperProcessor()
        return stripperProcessor.process(from: rootMarkup)
    }
    
    private func process(_ attributedString: NSAttributedString) -> RootMarkup {
        let processor = MarkdownStringToRootMarkupProcessor(markdowns: markdowns, rootStyle: rootStyle)
        return processor.process(from: attributedString)
    }
}
