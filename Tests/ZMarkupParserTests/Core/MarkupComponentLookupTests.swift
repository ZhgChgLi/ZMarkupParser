//
//  MarkupComponentLookupTests.swift
//
//
//  Verifies the `Sequence.buildLookup()` / `Dictionary.value(markup:)` extensions that
//  replaced the legacy O(N) `Array.first(where:)` scan. Visitor / selector hot paths now
//  query the dictionary instead of the array.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkupComponentLookupTests: XCTestCase {

    func testLookupReturnsValueForKnownMarkupAndNilForUnknown() {
        let m1 = RawStringMarkup(attributedString: NSAttributedString(string: "1"))
        let m2 = RawStringMarkup(attributedString: NSAttributedString(string: "2"))
        let m3 = RawStringMarkup(attributedString: NSAttributedString(string: "3"))

        let style1 = MarkupStyle(font: MarkupStyleFont(size: 12))
        let style2 = MarkupStyle(font: MarkupStyleFont(size: 16))

        let components: [MarkupStyleComponent] = [
            .init(markup: m1, value: style1),
            .init(markup: m2, value: style2)
        ]

        let lookup = components.buildLookup()
        XCTAssertEqual(lookup.value(markup: m1)?.font.size, 12)
        XCTAssertEqual(lookup.value(markup: m2)?.font.size, 16)
        XCTAssertNil(lookup.value(markup: m3), "markup not in components must return nil")
    }

    func testLookupHonorsObjectIdentity() {
        // Two RawStringMarkup instances wrapping the same string are still distinct objects;
        // the dictionary must distinguish them.
        let str = NSAttributedString(string: "same")
        let m1 = RawStringMarkup(attributedString: str)
        let m2 = RawStringMarkup(attributedString: str)

        let components: [MarkupStyleComponent] = [
            .init(markup: m1, value: MarkupStyle(font: MarkupStyleFont(size: 10)))
        ]

        let lookup = components.buildLookup()
        XCTAssertNotNil(lookup.value(markup: m1))
        XCTAssertNil(lookup.value(markup: m2), "look-up must compare object identity, not content")
    }

    func testLookupMatchesArrayValueResultForLargeInput() {
        // Sanity: results must be equivalent to the legacy `value(markup:)` array scan,
        // which is exactly the contract the visitor rewrite relies on.
        var markups: [RawStringMarkup] = []
        var components: [MarkupStyleComponent] = []
        for i in 0..<100 {
            let m = RawStringMarkup(attributedString: NSAttributedString(string: "\(i)"))
            markups.append(m)
            components.append(.init(markup: m, value: MarkupStyle(font: MarkupStyleFont(size: CGFloat(i)))))
        }

        let lookup = components.buildLookup()
        for m in markups {
            XCTAssertEqual(
                lookup.value(markup: m)?.font.size,
                components.value(markup: m)?.font.size,
                "dictionary lookup result must equal legacy array scan"
            )
        }
    }
}
