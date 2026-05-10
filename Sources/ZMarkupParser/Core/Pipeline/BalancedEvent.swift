//
//  BalancedEvent.swift
//
//
//  Stage 2 of the new HTML pipeline. After `HTMLScanner.scan` produces `[Token]`, the
//  reformatter walks them once linearly and emits a balanced event stream where every `open`
//  has a matching `close`. Staggered tags are auto-corrected by mirroring closes / re-opens at
//  the correction point. Isolated tags follow the legacy rules from
//  `HTMLParsedResultFormatterProcessor`: known WC3 tag with no attributes -> dropped to text;
//  otherwise -> downgraded to self-close.
//

import Foundation

enum BalancedEvent {
    case open(TagOpen, eventID: Int)
    case close(nameLower: String, matchedOpenID: Int)
    case selfClose(TagOpen)
    case text(Range<String.Index>)
}
