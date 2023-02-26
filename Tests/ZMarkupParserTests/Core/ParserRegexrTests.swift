//
//  ParserRegexrTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class ParserRegexrTests: XCTestCase {
    func testRawStringBetweenMatch() {
        let regxer = ParserRegexr(attributedString: NSAttributedString(string: "12345Z6789123Z456789"), pattern: "(Z)")!
        let matches = regxer.expression.matches(in: regxer.attributedString.string, range: NSMakeRange(0, regxer.totoalLength))
        
        XCTAssertEqual(regxer.rawStringBetweenMatch(lastMatch: nil, currentMatch: matches[0])?.string, "12345", "rawStringBetweenMatch at first should be `12345` in \(regxer.attributedString.string) with pattern `\(regxer.expression.pattern)`")
        XCTAssertEqual(regxer.rawStringBetweenMatch(lastMatch: matches[0], currentMatch: matches[1])?.string, "6789123", "rawStringBetweenMatch at second should be `6789123` in \(regxer.attributedString.string) with pattern `\(regxer.expression.pattern)`")
    }
    
    func testResetString() {
        let regxer = ParserRegexr(attributedString: NSAttributedString(string: "12345Z6789123Z456789"), pattern: "(Z)")!
        let matches = regxer.expression.matches(in: regxer.attributedString.string, range: NSMakeRange(0, regxer.totoalLength))
        
        XCTAssertEqual(regxer.resetString(lastMatch: matches.last)?.string, "456789", "resetString should be `456789` in \(regxer.attributedString.string) with pattern `\(regxer.expression.pattern)`")
        XCTAssertEqual(regxer.resetString(lastMatch: nil)?.string, regxer.attributedString.string, "resetString should be whole string in \(regxer.attributedString.string) with pattern `\(regxer.expression.pattern)`, when lastMatch is nil")
    }
    
    func testStringTotoalLength() {
        let string = "Test😄😄😄👨‍👨‍👧‍👧Test"
        XCTAssertEqual(ParserRegexr(attributedString: NSAttributedString(string: string), pattern: "(Z)")?.stringTotoalLength(), string.utf16.count, "Expected utf 16 count string.")
    }
}
