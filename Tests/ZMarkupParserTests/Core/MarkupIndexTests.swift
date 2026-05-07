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
        index.set(MarkupStyle(kern: 1), for: bold)
        index.set(MarkupStyle(kern: 2), for: italic)

        XCTAssertEqual(index.value(markup: bold)?.kern, 1)
        XCTAssertEqual(index.value(markup: italic)?.kern, 2)
        XCTAssertEqual(index.count, 2)
    }

    func testTwoInstancesOfSameClassDoNotCollide() {
        // Lookup must use Markup identity (===), not type or value equality.
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

    func testCarriesNonHashableValueType() {
        // HTMLElement isn't Hashable; the index is generic over arbitrary
        // Value types because keys come from Markup identity, not Value.
        var index = MarkupIndex<HTMLElementMarkupComponent.HTMLElement>()
        let bold = BoldMarkup()
        let element = HTMLElementMarkupComponent.HTMLElement(
            tag: HTMLTag(tagName: B_HTMLTagName()),
            tagAttributedString: NSAttributedString(string: "<b>"),
            attributes: nil
        )
        index.set(element, for: bold)

        XCTAssertEqual(index.value(markup: bold)?.tag.tagName.string, "b")
    }

    func testInitWithMinimumCapacityIsEquivalentToEmptyInit() {
        // The capacity hint must not change observable behavior.
        var hinted = MarkupIndex<Int>(minimumCapacity: 1024)
        XCTAssertTrue(hinted.isEmpty)
        XCTAssertEqual(hinted.count, 0)

        let bold = BoldMarkup()
        hinted.set(7, for: bold)
        XCTAssertEqual(hinted.value(markup: bold), 7)
    }

    func testReserveCapacityKeepsExistingEntries() {
        var index = MarkupIndex<Int>()
        let a = BoldMarkup()
        let b = ItalicMarkup()
        index.set(1, for: a)
        index.set(2, for: b)

        index.reserveCapacity(4096)

        XCTAssertEqual(index.count, 2)
        XCTAssertEqual(index.value(markup: a), 1)
        XCTAssertEqual(index.value(markup: b), 2)
    }
}
