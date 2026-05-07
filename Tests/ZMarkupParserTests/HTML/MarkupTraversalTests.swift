//
//  MarkupTraversalTests.swift
//
//
//  Correctness coverage for the visitor traversal paths after the
//  switch from `[Component]` linear-scan lookups to MarkupIndex.
//
//  The goal is functional regression: each test exercises a code
//  path that previously did a linear lookup over the components
//  array (style inheritance, list-item dispatch, child concatenation,
//  stripper). No timing assertions — those belong in the perf suite.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkupTraversalTests: XCTestCase {

    private func makeParser() -> ZHTMLParser {
        return ZHTMLParserBuilder.initWithDefault()
            .set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13)))
            .build()
    }

    // MARK: - collectMarkupStyle: ancestor walk

    func testNestedInlineTagsRenderText() {
        // 20-level <b> nest. The leaf's style is resolved by walking
        // 20 ancestors; the lookup at each ancestor must return the
        // tag's MarkupStyle.
        let depth = 20
        let html = String(repeating: "<b>", count: depth) + "x" + String(repeating: "</b>", count: depth)

        let rendered = makeParser().render(html)
        XCTAssertEqual(rendered.string, "x")
    }

    // MARK: - ListItem dispatch (cross-recursive visit)

    func testNestedListsRenderLeaf() {
        // 10-level <ul><li> nesting. List-item rendering recursively
        // calls visit() on grand-list-items to compute headIndent —
        // a code path that previously hit the linear-scan lookup
        // multiple times per ancestor.
        let depth = 10
        var html = ""
        for _ in 0..<depth { html += "<ul><li>" }
        html += "leaf"
        for _ in 0..<depth { html += "</li></ul>" }

        let rendered = makeParser().render(html).string
        XCTAssertTrue(rendered.contains("leaf"), "deeply nested list lost its leaf text: \(rendered)")
    }

    // MARK: - childMarkups concatenation

    func testManySiblingTagsAllRender() {
        // 100 sibling <b>i</b> tags exercise the collectAttributedString
        // for-loop that replaced compactMap+reduce.
        let count = 100
        var html = ""
        html.reserveCapacity(count * 8)
        for _ in 0..<count { html += "<b>i</b>" }

        let rendered = makeParser().render(html).string
        XCTAssertEqual(rendered.replacingOccurrences(of: "\n", with: "").count, count)
    }

    // MARK: - Stripper

    func testStripperOnNestedTreePreservesText() {
        let depth = 20
        let html = String(repeating: "<b>", count: depth) + "abc" + String(repeating: "</b>", count: depth)
        XCTAssertEqual(makeParser().stripper(html), "abc")
    }

    func testStripperOnBranchedTreeConcatenatesAllRawStrings() {
        // The previous tests only walked a single chain of children;
        // this one has multiple siblings at every level so the
        // append-into-mutable rewrite is exercised across forks.
        let html = "<p>one <b>two <i>three</i> four</b> five</p><p>six</p>"
        XCTAssertEqual(makeParser().stripper(html), "one two three four fivesix")
    }

    // MARK: - Empty content

    func testRenderOfEmptyInlineElementProducesEmptyString() {
        // collectAttributedString must handle a Markup whose childMarkups
        // is empty without producing junk output. This is the boundary
        // case the for-loop rewrite has to keep correct. <b> is inline
        // so no boundary breaklines are inserted.
        XCTAssertEqual(makeParser().render("<b></b>").string, "")
    }

    // MARK: - Style inheritance fixed point

    func testNestedStyleResolvesToInnermostFont() {
        // Verifies the per-node MarkupStyle stored in the MarkupIndex
        // is what the leaf inherits (and that the merge is stable).
        let parser = ZHTMLParserBuilder.initWithDefault()
            .add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold))))
            .build()

        let rendered = parser.render("<b>X</b>")
        let attrs = rendered.attributes(at: 0, effectiveRange: nil)
        #if canImport(UIKit)
        XCTAssertEqual((attrs[.font] as? UIFont)?.pointSize, 18)
        #elseif canImport(AppKit)
        XCTAssertEqual((attrs[.font] as? NSFont)?.pointSize, 18)
        #endif
    }
}
