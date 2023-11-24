//
//  RootMarkupRenderProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public enum ParagraphSpacingPolicy {
    ///
    /// In this mode, line break will be used to create spacing between paragraphs
    ///
    /// For example
    /// Line 1
    ///
    /// Line 2
    case lineBreaks
    ///
    /// In this mode new additional line breaks are added.
    ///
    /// Instead the MarkupStyleParagraphStyle.paragraphSpacing will create spacing between paragraphs.
    ///
    /// For example
    /// Line 1
    /// Line 2
    ///
    case paragraphSpacing
}


final class MarkupRenderProcessor: ParserProcessor {
    typealias From = (Markup, [MarkupStyleComponent])
    typealias To = NSAttributedString
    
    let rootStyle: MarkupStyle?
    let paragraphSpacingPolicy: ParagraphSpacingPolicy
    
    init(rootStyle: MarkupStyle?, paragraphSpacingPolicy: ParagraphSpacingPolicy = .lineBreaks) {
        self.rootStyle = rootStyle
        self.paragraphSpacingPolicy = paragraphSpacingPolicy
    }
    
    func process(from: From) -> To {
        let visitor = MarkupNSAttributedStringVisitor(
            components: from.1,
            rootStyle: rootStyle,
            paragraphSpacingPolicy: paragraphSpacingPolicy
        )
        return visitor.visit(markup: from.0)
    }
}
