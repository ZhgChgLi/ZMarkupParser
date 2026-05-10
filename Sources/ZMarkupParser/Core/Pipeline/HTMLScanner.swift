//
//  Scanner.swift
//
//
//  Stage 1 of the new HTML pipeline: cached static `NSRegularExpression`, scans `String` directly,
//  emits `[Token]` referencing `Range<String.Index>` into the source string. Comment / DOCTYPE
//  branches are dropped at scan time; raw text segments are trimmed of leading/trailing whitespace
//  + newline noise so that indented HTML markup does not leak indentation into the rendered output.
//
//  This file is added as part of Migration Step 3. The function is not yet wired into the hot
//  path; later steps will switch the parser entry points to it.
//

import Foundation

struct ScanResult {
    let tokens: [Token]
    let needFormatter: Bool
    /// retained so callers can resolve `Range<String.Index>` into `String(source[range])` lazily
    let source: String
}

enum HTMLScanner {
    static let tagRegex: NSRegularExpression = {
        return try! NSRegularExpression(
            pattern: HTMLStringToParsedResultProcessor.htmlTagRegexPattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )
    }()

    static let trimRegex: NSRegularExpression = {
        return try! NSRegularExpression(
            pattern: HTMLStringToParsedResultProcessor.htmlCommentOrDocumentHeaderRegexPattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )
    }()

    static func scan(_ source: String) -> ScanResult {
        var tokens: [Token] = []
        tokens.reserveCapacity(max(8, source.count / 32))
        var stackOpen: [TagOpen] = []
        var needFormatter = false
        let nsRange = NSRange(source.startIndex..<source.endIndex, in: source)
        var cursorOffset: Int = 0  // utf16 offset

        tagRegex.enumerateMatches(in: source, range: nsRange) { result, _, _ in
            guard let result = result else { return }
            let matchNSRange = result.range
            // emit raw text between cursor and match start
            if matchNSRange.location > cursorOffset {
                let textNSRange = NSRange(location: cursorOffset, length: matchNSRange.location - cursorOffset)
                emitText(textNSRange, in: source, into: &tokens)
            }
            cursorOffset = matchNSRange.upperBound

            // comment / DOCTYPE branch?
            let tagNameNSRange = result.range(withName: "tagName")
            guard tagNameNSRange.location != NSNotFound,
                  let matchSwiftRange = Range(matchNSRange, in: source),
                  let tagNameSwiftRange = Range(tagNameNSRange, in: source) else {
                return  // drop comment / DOCTYPE / out-of-range
            }

            let nameLower = source[tagNameSwiftRange]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            let isClose = isFlagPresent(result, name: "closeTag", in: source)
            let isSelfClose = isFlagPresent(result, name: "selfClosingTag", in: source)
            let attributesSwiftRange = Range(result.range(withName: "tagAttributes"), in: source)

            if isSelfClose {
                let open = TagOpen(
                    nameLower: nameLower,
                    rawRange: matchSwiftRange,
                    attributesRange: attributesSwiftRange
                )
                tokens.append(.selfClose(open))
            } else if isClose {
                if let idx = stackOpen.lastIndex(where: { $0.nameLower == nameLower }) {
                    if idx != stackOpen.count - 1 {
                        needFormatter = true
                    }
                    tokens.append(.close(TagClose(nameLower: nameLower, rawRange: matchSwiftRange)))
                    stackOpen.remove(at: idx)
                } else {
                    // isolated/redundant close tag: drop (matches legacy behavior)
                }
            } else {
                let open = TagOpen(
                    nameLower: nameLower,
                    rawRange: matchSwiftRange,
                    attributesRange: attributesSwiftRange
                )
                tokens.append(.start(open))
                stackOpen.append(open)
            }
        }

        // tail text
        let totalLength = nsRange.length
        if cursorOffset < totalLength {
            let tailNSRange = NSRange(location: cursorOffset, length: totalLength - cursorOffset)
            emitText(tailNSRange, in: source, into: &tokens)
        }

        // mark unclosed opens as isolated
        for open in stackOpen {
            open.isIsolated = true
            needFormatter = true
        }

        return ScanResult(tokens: tokens, needFormatter: needFormatter, source: source)
    }

    private static func isFlagPresent(_ result: NSTextCheckingResult, name: String, in source: String) -> Bool {
        let nsRange = result.range(withName: name)
        guard nsRange.location != NSNotFound,
              let r = Range(nsRange, in: source) else { return false }
        return source[r].trimmingCharacters(in: .whitespacesAndNewlines) == "/"
    }

    /// Trims leading/trailing whitespace+newline blocks from a raw segment using the cached
    /// `trimRegex`, mirroring the legacy `HTMLStringToParsedResultProcessor` behavior so indented
    /// HTML does not leak indentation through to the output.
    private static func emitText(_ segmentNSRange: NSRange, in source: String, into tokens: inout [Token]) {
        var lastEnd = segmentNSRange.location
        let segmentEnd = segmentNSRange.upperBound

        trimRegex.enumerateMatches(in: source, range: segmentNSRange) { result, _, _ in
            guard let result = result else { return }
            let matchRange = result.range
            if matchRange.location > lastEnd,
               let swiftRange = Range(NSRange(location: lastEnd, length: matchRange.location - lastEnd), in: source) {
                tokens.append(.text(swiftRange))
            }
            lastEnd = matchRange.upperBound
        }

        if lastEnd < segmentEnd,
           let swiftRange = Range(NSRange(location: lastEnd, length: segmentEnd - lastEnd), in: source) {
            tokens.append(.text(swiftRange))
        }
    }
}
