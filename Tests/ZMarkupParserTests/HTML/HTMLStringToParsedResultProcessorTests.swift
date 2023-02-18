//
//  HTMLStringToParsedResultProcessorTests.swift
//  
//
//  Created by ZhgChgLi on 2023/2/18.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLStringToParsedResultProcessorTests: XCTestCase {
    func testProcess() {
        let result = HTMLStringToParsedResultProcessor().process(from: NSAttributedString(string: "Test<a href=\"https://zhgchg.li/about?g=f#hey\" style=\"color:red\">Hello</a>Zhgchgli.<br/>C<br />B"))
        XCTAssertEqual(result.count, 9, "Should have 9 elements.")
        
        for (index, item) in result.enumerated() {
            switch index {
            case 0:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "Test", "expected `Test` at index:\(index).")
                } else{
                    XCTFail("expected `Test` at index:\(index).")
                }
            case 1:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertEqual(startItem.tagName, "a", "expected `a` tag at index:\(index).")
                    XCTAssertEqual(startItem.attributes?.count, 2, "expected 2 attributes in `a` tag at index:\(index).")
                    XCTAssertEqual(startItem.attributes?["href"], "https://zhgchg.li/about?g=f#hey", "expected  href attribute in `a` tag at index:\(index).")
                    XCTAssertEqual(startItem.attributes?["style"], "color:red", "expected  style attribute in `a` tag at index:\(index).")
                } else{
                    XCTFail("expected a tag at index:\(index).")
                }
            case 2:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "Hello", "expected `Hello` at index:\(index).")
                } else{
                    XCTFail("expected `Hello` at index:\(index).")
                }
            case 3:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertEqual(closeItem.tagName, "a", "expected `a` tag at index:\(index).")
                } else{
                    XCTFail("expected `a` tag at index:\(index).")
                }
            case 4:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "Zhgchgli.", "expected `Zhgchgli.` at index:\(index).")
                } else{
                    XCTFail("expected `Zhgchgli.` at index:\(index).")
                }
            case 5:
                if case let HTMLParsedResult.selfClosing(selfClosingItem) = item {
                    XCTAssertEqual(selfClosingItem.tagName, "br", "expected `br` tag at index:\(index).")
                } else{
                    XCTFail("expected `br` tag at index:\(index).")
                }
            case 6:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "C", "expected `C` at index:\(index).")
                } else{
                    XCTFail("expected `C` at index:\(index).")
                }
            case 7:
                if case let HTMLParsedResult.selfClosing(selfClosingItem) = item {
                    XCTAssertEqual(selfClosingItem.tagName, "br", "expected `br` tag at index:\(index).")
                } else{
                    XCTFail("expected `br` tag at index:\(index).")
                }
            case 8:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "B", "expected `B` at index:\(index).")
                } else{
                    XCTFail("expected `B` at index:\(index).")
                }
            default:
                XCTFail("unexpected result.")
            }
        }
    }
}
