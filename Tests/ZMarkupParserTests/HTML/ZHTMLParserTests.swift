//
//  ZHTMLParserTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class ZHTMLParserTests: XCTestCase {

    private let parser = ZHTMLParser(htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0) }), styleAttributes: ZHTMLParserBuilder.styleAttributes, rootStyle: MarkupStyle(kern: 999))

    func testRender() {
        let string = "Test<a href=\"https://zhgchg.li\">Qoo</a>DDD"
        let renderResult = parser.render(string)
        XCTAssertEqual(renderResult.string, "TestQooDDD")
        XCTAssertEqual(renderResult.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 999)
        
        XCTAssertEqual(renderResult.attributedSubstring(from: NSString(string: renderResult.string).range(of: "Qoo")).attributes(at: 0, effectiveRange: nil)[.link] as? URL, URL(string: "https://zhgchg.li"))
        
        let expectation = XCTestExpectation(description: #function)
        parser.render(string) { renderResult in
            XCTAssertEqual(renderResult.string, "TestQooDDD")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testSelector() {
        let string = "Test<a href=\"https://zhgchg.li\">Qfsa<b>fas</b>foo</a>DDD"
        let selectorResult = parser.selector(string)
        XCTAssertEqual(selectorResult.first("a")?.first("b")?.attributedString.string, "fas")
        let renderResult = parser.render(selectorResult.first("a")!)
        XCTAssertEqual(renderResult.string, "Qfsafasfoo")
        XCTAssertEqual(renderResult.attributedSubstring(from: NSString(string: renderResult.string).range(of: "Qfsafasfoo")).attributes(at: 0, effectiveRange: nil)[.link] as? URL, URL(string: "https://zhgchg.li"))
        
        let expectation1 = XCTestExpectation(description: #function)
        parser.selector(string) { selectorResult in
            XCTAssertEqual(selectorResult.first("a")?.first("b")?.attributedString.string, "fas")
            expectation1.fulfill()
        }
        
        let expectation2 = XCTestExpectation(description: #function)
        parser.render(selectorResult.first("a")!) { renderResult in
            XCTAssertEqual(renderResult.string, "Qfsafasfoo")
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
    }
    
    func testStripper() {
        let attributedString = NSAttributedString(string: "Test<a href=\"https://zhgchg.li\">Qoo</a>DDD")
        let stripperResult = parser.stripper(attributedString)
        XCTAssertEqual(stripperResult.string, "TestQooDDD")
        
        let expectation = XCTestExpectation(description: #function)
        parser.stripper(attributedString) { stripperResult in
            XCTAssertEqual(stripperResult.string, "TestQooDDD")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
