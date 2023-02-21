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
        return attributedString(from)
    }
    
    private func attributedString(_ markup: Markup) -> NSAttributedString {
        if let rawStringMarkup = markup as? RawStringMarkup {
            return rawStringMarkup.attributedString
        } else {
            return markup.childMarkups.compactMap({ attributedString($0) }).reduce(NSMutableAttributedString()) { partialResult, attributedString in
                partialResult.append(attributedString)
                return partialResult
            }
        }
    }
}
