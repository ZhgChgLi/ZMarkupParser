//
//  MarkupTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkupTests: XCTestCase {
    func testAppendChilds() {
        let rootMarkup = RootMarkup()
        let rawStringMarkup = RawStringMarkup(attributedString: NSAttributedString(string: "test"))
        rootMarkup.appendChild(markup: BoldMarkup())
        rootMarkup.appendChild(markup: rawStringMarkup)
        
        XCTAssertEqual(rootMarkup.childMarkups.count, 2, "Should append 1 child to RootMarkup.")
        XCTAssertEqual((rootMarkup.childMarkups[1] as? RawStringMarkup)?.attributedString.string, "test", "Should append rawString(test) child to RootMarkup at last.")
        XCTAssertTrue(rawStringMarkup.parentMarkup === rootMarkup, "rawString(test)'s parent markup should be rootMarkup.")
    }
    
    func testPrependChilds() {
        let rootMarkup = RootMarkup()
        let rawStringMarkup = RawStringMarkup(attributedString: NSAttributedString(string: "test"))
        rootMarkup.appendChild(markup: BoldMarkup())
        rootMarkup.prependChild(markup: rawStringMarkup)
        
        XCTAssertEqual(rootMarkup.childMarkups.count, 2, "Should prepend 1 child to RootMarkup.")
        XCTAssertEqual((rootMarkup.childMarkups[0] as? RawStringMarkup)?.attributedString.string, "test", "Should prepend rawString(test) child to RootMarkup at first.")
        XCTAssertTrue(rawStringMarkup.parentMarkup === rootMarkup, "rawString(test)'s parent markup should be rootMarkup.")
    }
}
