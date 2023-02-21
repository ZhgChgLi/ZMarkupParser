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
    func testNormalProcess() {
        let result = HTMLStringToParsedResultProcessor().process(from: NSAttributedString(string: "Test<a href=\"https://zhgchg.li/about?g=f#hey\" style=\"color:red\">Hello<b>ssss</a>Zhg</b>chgli<br>.<br/>C<br />B"))
        let items = result.items
        XCTAssertEqual(items.count, 15, "Should have 15 elements.")
        XCTAssertEqual(result.needFormatter, true, "Should have need formatter.")
        
        for (index, item) in items.enumerated() {
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
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertEqual(startItem.tagName, "b", "expected `b` at index:\(index).")
                } else{
                    XCTFail("expected `b` at index:\(index).")
                }
            case 4:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "ssss", "expected `ssss` at index:\(index).")
                } else{
                    XCTFail("expected `ssss` at index:\(index).")
                }
            case 5:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertEqual(closeItem.tagName, "a", "expected `a` at index:\(index).")
                } else{
                    XCTFail("expected `a` at index:\(index).")
                }
            case 6:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "Zhg", "expected `Zhg` at index:\(index).")
                } else{
                    XCTFail("expected `Zhg` at index:\(index).")
                }
            case 7:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertEqual(closeItem.tagName, "b", "expected `b` at index:\(index).")
                } else{
                    XCTFail("expected `b` at index:\(index).")
                }
            case 8:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "chgli", "expected `chgli` at index:\(index).")
                } else{
                    XCTFail("expected `chgli` at index:\(index).")
                }
            case 9:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertEqual(startItem.tagName, "br", "expected `br` tag at index:\(index).")
                } else{
                    XCTFail("expected `br` tag at index:\(index).")
                }
            case 10:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, ".", "expected `.` at index:\(index).")
                } else{
                    XCTFail("expected `.` at index:\(index).")
                }
            case 11:
                if case let HTMLParsedResult.selfClosing(selfClosingItem) = item {
                    XCTAssertEqual(selfClosingItem.tagName, "br", "expected `br` tag at index:\(index).")
                } else{
                    XCTFail("expected `br` tag at index:\(index).")
                }
            case 12:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, "C", "expected `C` at index:\(index).")
                } else{
                    XCTFail("expected `C` at index:\(index).")
                }
            case 13:
                if case let HTMLParsedResult.selfClosing(selfClosingItem) = item {
                    XCTAssertEqual(selfClosingItem.tagName, "br", "expected `br` tag at index:\(index).")
                } else{
                    XCTFail("expected `br` tag at index:\(index).")
                }
            case 14:
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
