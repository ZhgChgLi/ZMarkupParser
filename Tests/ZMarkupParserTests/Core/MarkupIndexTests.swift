//
//  MarkupIndexTests.swift
//
//
//  Tests the O(1) Markup → Value lookup table that replaced the
//  old `[MarkupComponent]` linear scan.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkupIndexTests: XCTestCase {

    func testEmptyIndex() {
        let index = MarkupIndex<MarkupStyle>()
        XCTAssertTrue(index.isEmpty)
        XCTAssertEqual(index.count, 0)
        XCTAssertNil(index.value(markup: BoldMarkup()))
    }

    func testKeyedByMarkupIdentity() {
        var index = MarkupIndex<MarkupStyle>()
        let bold = BoldMarkup()
        let italic = ItalicMarkup()
        let style1 = MarkupStyle(kern: 1)
        let style2 = MarkupStyle(kern: 2)

        index.set(style1, for: bold)
        index.set(style2, for: italic)

        XCTAssertEqual(index.value(markup: bold)?.kern, 1)
        XCTAssertEqual(index.value(markup: italic)?.kern, 2)
        XCTAssertEqual(index.count, 2)
    }

    func testIdentityNotEquality() {
        // Two distinct markup instances of the same type must not collide.
        var index = MarkupIndex<Int>()
        let a = BoldMarkup()
        let b = BoldMarkup()
        index.set(1, for: a)
        index.set(2, for: b)

        XCTAssertEqual(index.value(markup: a), 1)
        XCTAssertEqual(index.value(markup: b), 2)
    }

    func testSetReplacesExistingValue() {
        var index = MarkupIndex<Int>()
        let bold = BoldMarkup()
        index.set(1, for: bold)
        index.set(2, for: bold)

        XCTAssertEqual(index.value(markup: bold), 2)
        XCTAssertEqual(index.count, 1)
    }

    func testValueCarriesNonHashableType() {
        // HTMLElement isn't Hashable; the index keys on Markup identity, not value.
        var index = MarkupIndex<HTMLElementMarkupComponent.HTMLElement>()
        let bold = BoldMarkup()
        let element = HTMLElementMarkupComponent.HTMLElement(tag: HTMLTag(tagName: B_HTMLTagName()), tagAttributedString: NSAttributedString(string: "<b>"), attributes: nil)
        index.set(element, for: bold)

        XCTAssertEqual(index.value(markup: bold)?.tag.tagName.string, "b")
    }

    func testLookupIsConstantTimeAtScale() {
        // Functional regression guard for the perf fix: even at 5k entries,
        // a lookup must complete near-instantly. Before the refactor the
        // equivalent linear scan over a 5k-element array was the hot path
        // that turned end-to-end render into O(N²).
        var index = MarkupIndex<Int>()
        var markups: [Markup] = []
        let n = 5_000
        markups.reserveCapacity(n)
        for i in 0..<n {
            let m = InlineMarkup()
            markups.append(m)
            index.set(i, for: m)
        }

        let start = CFAbsoluteTimeGetCurrent()
        for (i, m) in markups.enumerated() {
            XCTAssertEqual(index.value(markup: m), i)
        }
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        // Generous bound to avoid flakes on slow CI; the linear-scan version
        // would be ~5000× slower and well over this.
        XCTAssertLessThan(elapsed, 1.0, "MarkupIndex lookup should be O(1); 5k lookups took \(elapsed)s")
    }
}
