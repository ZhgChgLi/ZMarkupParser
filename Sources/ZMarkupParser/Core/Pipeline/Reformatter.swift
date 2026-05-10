//
//  Reformatter.swift
//
//
//  Stage 2 of the new HTML pipeline. Linear stream rewrite that replaces the legacy
//  `HTMLParsedResultFormatterProcessor`'s `array.insert(contentsOf:at:)` with append-only writes.
//  Mirrors the auto-correction behavior tested by `HTMLParsedResultFormatterProcessorTests`.
//
//  Added in Migration Step 4. Not yet wired into the hot path; later steps will switch the
//  parser to use `Reformatter.reformat` directly.
//

import Foundation

enum Reformatter {
    /// Linearly walks the scanner's `[Token]` and emits a balanced `[BalancedEvent]` stream.
    /// Every `.open` is guaranteed to have a matching `.close`. Staggered tags
    /// (`<a><b></a></b>`) are corrected via mirror-close + mirror-reopen with fresh event IDs.
    static func reformat(_ tokens: [Token]) -> [BalancedEvent] {
        var output: [BalancedEvent] = []
        output.reserveCapacity(tokens.count + 8)
        var openStack: [(open: TagOpen, eventID: Int)] = []
        var nextID = 0

        @discardableResult
        func emitOpen(_ open: TagOpen) -> Int {
            let id = nextID
            nextID += 1
            output.append(.open(open, eventID: id))
            openStack.append((open, id))
            return id
        }

        func emitClose(_ entry: (open: TagOpen, eventID: Int)) {
            output.append(.close(nameLower: entry.open.nameLower, matchedOpenID: entry.eventID))
        }

        for token in tokens {
            switch token {
            case .text(let range):
                output.append(.text(range))
            case .selfClose(let open):
                output.append(.selfClose(open))
            case .start(let open):
                if open.isIsolated {
                    // Legacy rule: known WC3 tag with no attributes -> drop the tag (its raw
                    // markup becomes text); otherwise -> downgrade to self-close so it still
                    // renders some marker.
                    let hasAttributes = !(open.parsedAttributes?.isEmpty ?? true)
                    if WC3HTMLTagName(rawValue: open.nameLower) == nil && !hasAttributes {
                        output.append(.text(open.rawRange))
                    } else {
                        output.append(.selfClose(open))
                    }
                } else {
                    emitOpen(open)
                }
            case .close(let close):
                guard let idx = openStack.lastIndex(where: { $0.open.nameLower == close.nameLower }) else {
                    // isolated/redundant close: drop
                    continue
                }
                if idx == openStack.count - 1 {
                    // already on top, normal pair close
                    let entry = openStack.removeLast()
                    emitClose(entry)
                } else {
                    // staggered: close everything above `idx` (innermost first), close the
                    // target itself, then re-open everything that was above `idx` with fresh
                    // event IDs so the new spans are tracked separately.
                    let above = Array(openStack[(idx + 1)...])
                    for entry in above.reversed() {
                        emitClose(entry)
                    }
                    let target = openStack[idx]
                    emitClose(target)
                    openStack.removeSubrange(idx...)
                    for entry in above {
                        emitOpen(entry.open)
                    }
                }
            }
        }

        // Defensive tail: any remaining opens are unbalanced. The scanner already marks
        // unclosed opens as isolated (transformed above), so this should normally be empty.
        // If somehow not, synthesise closes to keep the stream balanced.
        for entry in openStack.reversed() {
            emitClose(entry)
        }

        return output
    }
}
