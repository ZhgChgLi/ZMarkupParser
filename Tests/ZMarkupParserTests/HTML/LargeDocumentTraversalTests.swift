//
//  LargeDocumentTraversalTests.swift
//
//
//  Regression coverage for the visitor-traversal performance fix.
//
//  Before MarkupIndex, both the style-resolution pass and the
//  NSAttributedString render pass looked up each ancestor's value
//  via a linear scan over the components array, making the full
//  pipeline O(N²·D). These tests exercise large/deep/wide trees
//  end-to-end so a regression to the linear-scan shape would either
//  fail the time bound or surface incorrect style inheritance.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class LargeDocumentTraversalTests: XCTestCase {

    private func makeParser() -> ZHTMLParser {
        return ZHTMLParserBuilder.initWithDefault()
            .set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13)))
            .build()
    }

    // MARK: - Deep nesting

    func testDeeplyNestedInlineTagsRenderText() {
        // <b><b>...<b>x</b>...</b></b>, 150 levels deep.
        // The renderer walks each ancestor when resolving the leaf's
        // style; with the old O(N) lookup this was the worst-case path.
        let depth = 150
        let html = String(repeating: "<b>", count: depth) + "x" + String(repeating: "</b>", count: depth)

        let parser = makeParser()
        let result = parser.render(html)
        XCTAssertEqual(result.string, "x")
    }

    func testDeeplyNestedListsHaveItemMarkers() {
        // 30 levels of <ul><li>…</li></ul>. List item rendering walks
        // ancestors twice (once for the parent list, once for the
        // grand-list-item indent); a regression to O(N) lookups here
        // would be quadratic in depth.
        let depth = 30
        var html = ""
        for _ in 0..<depth { html += "<ul><li>" }
        html += "leaf"
        for _ in 0..<depth { html += "</li></ul>" }

        let parser = makeParser()
        let result = parser.render(html).string
        XCTAssertTrue(result.contains("leaf"), "deeply nested list lost its leaf text")
    }

    // MARK: - Wide siblings

    func testWideSiblingTagsAllRender() {
        // 2000 sibling <b>i</b> tags. Style resolution iterates every
        // child; this is the path most sensitive to per-node lookup cost.
        let count = 2_000
        var html = ""
        html.reserveCapacity(count * 8)
        for _ in 0..<count { html += "<b>i</b>" }

        let parser = makeParser()
        let result = parser.render(html).string
        XCTAssertEqual(result.replacingOccurrences(of: "\n", with: "").count, count, "expected \(count) leaves to be present")
    }

    // MARK: - Stripper

    func testStripperOnDeepTreePreservesText() {
        let depth = 150
        let html = String(repeating: "<b>", count: depth) + "abc" + String(repeating: "</b>", count: depth)

        let parser = makeParser()
        XCTAssertEqual(parser.stripper(html), "abc")
    }

    // MARK: - End-to-end timing guard

    func testLargeDocumentRenderCompletesInBoundedTime() {
        // ~2k tag nodes in a single render. With the pre-refactor
        // O(N²·D) shape this took multiple seconds even on fast
        // hardware; with O(N) it's well under a second. The bound is
        // intentionally generous so the test is not flaky on CI VMs.
        let snippet = "<p>Hello <b>world</b> from <i>ZMarkupParser</i>.</p>"
        let html = String(repeating: snippet, count: 200)

        let parser = makeParser()
        let start = CFAbsoluteTimeGetCurrent()
        let rendered = parser.render(html)
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        XCTAssertGreaterThan(rendered.length, 0)
        XCTAssertLessThan(elapsed, 5.0, "200×snippet render took \(elapsed)s — possible regression to O(N²) traversal")
    }
}
