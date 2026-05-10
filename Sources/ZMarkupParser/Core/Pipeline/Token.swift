//
//  Token.swift
//
//
//  Internal scanner / pipeline token. Replaces the legacy `HTMLParsedResult` enum on the hot path
//  in subsequent migration steps; does not affect any public API.
//

import Foundation

enum Token {
    case text(Range<String.Index>)
    case start(TagOpen)
    case close(TagClose)
    case selfClose(TagOpen)
}

final class TagOpen {
    let nameLower: String
    let rawRange: Range<String.Index>
    let attributesRange: Range<String.Index>?
    var parsedAttributes: [String: String]?
    var isIsolated: Bool

    init(
        nameLower: String,
        rawRange: Range<String.Index>,
        attributesRange: Range<String.Index>?,
        parsedAttributes: [String: String]? = nil,
        isIsolated: Bool = false
    ) {
        self.nameLower = nameLower
        self.rawRange = rawRange
        self.attributesRange = attributesRange
        self.parsedAttributes = parsedAttributes
        self.isIsolated = isIsolated
    }
}

struct TagClose {
    let nameLower: String
    let rawRange: Range<String.Index>
}
