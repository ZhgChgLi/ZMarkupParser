//
//  RootMarkupStripperProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class MarkupStripperProcessor: ParserProcessor {
    typealias From = Markup
    typealias To = NSAttributedString

    func process(from: From) -> To {
        let result = NSMutableAttributedString()
        append(markup: from, into: result)
        return result
    }

    private func append(markup: Markup, into result: NSMutableAttributedString) {
        if let rawStringMarkup = markup as? RawStringMarkup {
            result.append(rawStringMarkup.attributedString)
            return
        }
        for child in markup.childMarkups {
            append(markup: child, into: result)
        }
    }
}
