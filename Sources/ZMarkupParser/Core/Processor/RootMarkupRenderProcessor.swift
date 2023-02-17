//
//  RootMarkupRenderProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class RootMarkupRenderProcessor: ParserProcessor {
    typealias From = RootMarkup
    typealias To = NSAttributedString
    
    private let visitor = MarkupNSAttributedStringVisitor()
    
    func process(from: From) -> To {
        return visitor.visit(from)
    }
}
