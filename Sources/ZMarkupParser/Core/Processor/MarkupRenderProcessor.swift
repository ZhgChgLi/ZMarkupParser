//
//  RootMarkupRenderProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class MarkupRenderProcessor: ParserProcessor {
    typealias From = (Markup, [MarkupStyleComponent])
    typealias To = NSAttributedString
    
    let rootStyle: MarkupStyle?
    
    init(rootStyle: MarkupStyle?) {
        self.rootStyle = rootStyle
    }
    
    func process(from: From) -> To {
        let visitor = MarkupNSAttributedStringVisitor(
            components: from.1,
            rootStyle: rootStyle
        )
        return visitor.visit(markup: from.0)
    }
}
