//
//  HTMLScannerTests.swift
//
//
//  Direct coverage for the new pure-`String` Stage 1 scanner that
//  `HTMLStringToParsedResultProcessor.process` now delegates to. The processor-level test
//  (`HTMLStringToParsedResultProcessorTests.testNormalProcess`) covers the integrated
//  behavior; this suite exercises the `Token` / `TagOpen` / `TagClose` payload contract
//  directly so future changes to the scanner are caught without going through the
//  `HTMLParsedResult` adapter.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLScannerTests: XCTestCase {

    func testScansPlainTextOnlyAsSingleTextToken() {
        let result = HTMLScanner.scan("Hello, world")
        XCTAssertEqual(result.tokens.count, 1)
        XCTAssertFalse(result.needFormatter)
        if case .text(let range) = result.tokens[0] {
            XCTAssertEqual(String(result.source[range]), "Hello, world")
        } else {
            XCTFail("expected single text token")
        }
    }

    func testScansBalancedTagPair() {
        let source = "<a href=\"https://zhgchg.li\">Link</a>"
        let result = HTMLScanner.scan(source)
        XCTAssertFalse(result.needFormatter)
        XCTAssertEqual(result.tokens.count, 3)

        guard case .start(let open) = result.tokens[0] else { return XCTFail("expected start") }
        XCTAssertEqual(open.nameLower, "a")
        XCTAssertFalse(open.isIsolated)

        guard case .text(let textRange) = result.tokens[1] else { return XCTFail("expected text") }
        XCTAssertEqual(String(source[textRange]), "Link")

        guard case .close(let close) = result.tokens[2] else { return XCTFail("expected close") }
        XCTAssertEqual(close.nameLower, "a")
    }

    func testRecognizesSelfClosingTags() {
        let source = "before<br/>middle<img src=\"x\"/>after"
        let result = HTMLScanner.scan(source)
        let kinds = result.tokens.map { token -> String in
            switch token {
            case .text: return "text"
            case .start: return "start"
            case .close: return "close"
            case .selfClose(let open): return "self<\(open.nameLower)>"
            }
        }
        XCTAssertEqual(kinds, ["text", "self<br>", "text", "self<img>", "text"])
    }

    func testFlagsStaggeredCloseAsNeedFormatter() {
        // <a><b></a></b> — `</a>` closes a tag that is not on top of the open stack.
        let result = HTMLScanner.scan("<a><b></a></b>")
        XCTAssertTrue(result.needFormatter, "staggered close must trigger needFormatter")
    }

    func testIsolatedOpenTagsAreMarkedIsolated() {
        // `<Hot>` is opened but never closed — should be flagged as isolated.
        let source = "<Hot>"
        let result = HTMLScanner.scan(source)
        XCTAssertTrue(result.needFormatter)
        guard case .start(let open) = result.tokens.last! else { return XCTFail("expected start token") }
        XCTAssertTrue(open.isIsolated)
        XCTAssertEqual(open.nameLower, "hot")
    }

    func testCommentAndDoctypeAreDroppedAtScanTime() {
        let result = HTMLScanner.scan("<!DOCTYPE html><!-- a comment --><p>x</p>")
        let kinds = result.tokens.map { token -> String in
            switch token {
            case .text: return "text"
            case .start(let o): return "<\(o.nameLower)>"
            case .close(let c): return "</\(c.nameLower)>"
            case .selfClose(let o): return "<\(o.nameLower)/>"
            }
        }
        // Comment and DOCTYPE should not appear; only the <p>x</p> trio remains.
        XCTAssertEqual(kinds, ["<p>", "text", "</p>"])
    }

    func testCaseInsensitiveTagsLowercased() {
        let result = HTMLScanner.scan("<DIV><B>x</B></DIV>")
        let names: [String] = result.tokens.compactMap { token in
            switch token {
            case .start(let o): return o.nameLower
            case .close(let c): return c.nameLower
            case .selfClose(let o): return o.nameLower
            case .text: return nil
            }
        }
        XCTAssertEqual(names, ["div", "b", "b", "div"])
    }

    func testTrimsLeadingAndTrailingWhitespaceNewlinesBetweenTags() {
        // The legacy raw-string trimmer removes blank-newline-blank padding around tags so
        // indented HTML does not bleed indentation into the rendered output.
        let result = HTMLScanner.scan("<p>\n  hello  \n</p>")
        // Must yield: start, text=" hello "/"hello" (trimmed of surrounding newlines), close
        let texts: [String] = result.tokens.compactMap { token in
            if case .text(let range) = token { return String(result.source[range]) }
            return nil
        }
        XCTAssertEqual(texts.count, 1)
        XCTAssertFalse(texts[0].contains("\n"), "leading/trailing whitespace+newline should be trimmed")
    }

    func testEmojiAndSurrogatePairBoundariesPreserved() {
        let source = "🎄<b>x</b>🎁"
        let result = HTMLScanner.scan(source)
        let texts: [String] = result.tokens.compactMap { token in
            if case .text(let range) = token { return String(result.source[range]) }
            return nil
        }
        XCTAssertTrue(texts.contains("🎄"), "leading emoji must be a separate text token")
        XCTAssertTrue(texts.contains("🎁"), "trailing emoji must be a separate text token")
        XCTAssertTrue(texts.contains("x"), "tag-internal text must be preserved")
    }

    func testSourceFieldRoundTripsRangesIntoString() {
        let source = "Test<b>HelloBold</b>End"
        let result = HTMLScanner.scan(source)
        // Reconstruct the visible characters using the token ranges and verify they
        // assemble to "TestHelloBoldEnd" (i.e. tags removed but text preserved verbatim).
        var rebuilt = ""
        for token in result.tokens {
            if case .text(let range) = token {
                rebuilt += String(result.source[range])
            }
        }
        XCTAssertEqual(rebuilt, "TestHelloBoldEnd")
    }
}
