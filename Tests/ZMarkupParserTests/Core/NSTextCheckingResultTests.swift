//
//  NSTextCheckingResultTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class NSTextCheckingResultTests: XCTestCase {
    func testGetRangeAttributedString() {
        let attributedString = NSAttributedString(string: "12345Z6789123Z456789")
        let expression = try! NSRegularExpression(pattern: "((?<Test>[0-9]+)Z)")
        let match = expression.firstMatch(in: attributedString.string, range: NSMakeRange(0, attributedString.string.utf16.count))!
        
        XCTAssertEqual(match.attributedString(attributedString, with: match.range)?.string, "12345Z", "Should be `12345Z` substring of \(attributedString.string) with pattern \(expression.pattern)")
        XCTAssertEqual(match.attributedString(attributedString, at: 2)?.string, "12345", "Should be `12345` substring of \(attributedString.string) with pattern \(expression.pattern)")
        XCTAssertEqual(match.attributedString(attributedString, with: "Test")?.string, "12345", "Should be `12345` substring of \(attributedString.string) with pattern \(expression.pattern)")
    }
    
    func testGetOutOfRangeAttributedString() {
        let attributedString = NSAttributedString(string: "12345Z")
        let expression = try! NSRegularExpression(pattern: "(Z)")
        let match = expression.firstMatch(in: attributedString.string, range: NSMakeRange(0, attributedString.string.utf16.count))!
        
        XCTAssertNil(match.attributedString(attributedString, at: 99), "out of range, should be nil")
        XCTAssertNil(match.attributedString(attributedString, with: "Not"), "not a vaild group name, should be nil")
    }
}
