//
//  HTMLStringTests.swift
//  
//
//  Created by zhgchgli on 2023/8/15.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLStringTests: XCTestCase {
    func testAddingUnicodeEntities() {
        let string = "Fish & Chips"
        let result = string.addingUnicodeEntities()
        XCTAssertEqual(result, "Fish &#38; Chips")
    }
    
    func testAddingASCIIEntities() {
        let string = "Fish & Chips"
        let result = string.addingASCIIEntities()
        XCTAssertEqual(result, "Fish &#38; Chips")

        let stringWithUnicode = "Σ"
        let resultWithUnicode = stringWithUnicode.addingASCIIEntities()
        XCTAssertEqual(resultWithUnicode, "&#931;")

        let stringWithEmoji = "🇺🇸"
        let resultWithEmoji = stringWithEmoji.addingASCIIEntities()
        XCTAssertEqual(resultWithEmoji, "&#127482;&#127480;")
    }

    func testRemovingHTMLEntities() {
        let string = "Fish &#38; Chips"
        let result = string.removingHTMLEntities()
        XCTAssertEqual(result, "Fish & Chips")

        let stringWithUnicode = "&#931;"
        let resultWithUnicode = stringWithUnicode.removingHTMLEntities()
        XCTAssertEqual(resultWithUnicode, "Σ")

        let stringWithEmoji = "&#127482;&#127480;"
        let resultWithEmoji = stringWithEmoji.removingHTMLEntities()
        XCTAssertEqual(resultWithEmoji, "🇺🇸")
    }
}
