//
//  HTMLParsedResultFormatterProcessorTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/17.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLParsedResultFormatterProcessorTests: XCTestCase {
    func testFormatterIfStaggered() {
        
        // <Hot><a>linkString<b>linkAndBoldString</a>boldString</b>
        let hotStartItem = HTMLParsedResult.StartItem(tagName: "Hot", tagAttributedString: NSAttributedString(string: "<Hot>"), attributes: nil)
        let aStartItem = HTMLParsedResult.StartItem(tagName: "a", tagAttributedString: NSAttributedString(string: "<a>"), attributes: nil)
        let bStartItem = HTMLParsedResult.StartItem(tagName: "b", tagAttributedString: NSAttributedString(string: "<b rel=\"zhg\">"), attributes: ["rel":"zhg"])
        let aCloseItem = HTMLParsedResult.CloseItem(tagName: "a")
        let bCloseItem = HTMLParsedResult.CloseItem(tagName: "b")

        let linkString = NSAttributedString(string: "linkString")
        let linkAndBoldString = NSAttributedString(string: "linkAndBoldString")
        let boldString = NSAttributedString(string: "boldString")
        
        let parsedResult: [HTMLParsedResult] = [
            .start(hotStartItem),
            .start(aStartItem),
            .rawString(linkString),
            .start(bStartItem),
            .rawString(linkAndBoldString),
            .close(aCloseItem),
            .rawString(boldString),
            .close(bCloseItem)
        ]
        
        // expected: // <Hot><a>linkString<b>linkAndBoldString</b></a><b>boldString</b>
        let result = HTMLParsedResultFormatterProcessor().process(from: parsedResult)
        XCTAssertEqual(result.count, 10)
        
        for (index, item) in result.enumerated() {
            switch index {
            case 0:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertTrue(startItem === hotStartItem, "expected \(hotStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(hotStartItem) at index:\(index).")
                }
            case 1:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertTrue(startItem === aStartItem, "expected \(aStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(aStartItem) at index:\(index).")
                }
            case 2:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, linkString.string, "expected \(linkString) at index:\(index).")
                } else{
                    XCTFail("expected \(linkString) at index:\(index).")
                }
            case 3:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertTrue(startItem === bStartItem, "expected \(bStartItem) at index:\(index).")
                    XCTAssertEqual(startItem.attributes!["rel"], bStartItem.attributes!["rel"], "expected \(bStartItem) at index:\(index).")
                    XCTAssertEqual(startItem.tagAttributedString.string, bStartItem.tagAttributedString.string, "expected \(bStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bStartItem) at index:\(index).")
                }
            case 4:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, linkAndBoldString.string, "expected \(linkAndBoldString) at index:\(index).")
                } else{
                    XCTFail("expected \(linkAndBoldString) at index:\(index).")
                }
            case 5:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertEqual(closeItem.tagName, bStartItem.tagName, "expected \(bStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bStartItem) at index:\(index).")
                }
            case 6:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertTrue(closeItem === aCloseItem, "expected \(aCloseItem) at index:\(index).")
                } else{
                    XCTFail("expected \(aCloseItem) at index:\(index).")
                }
            case 7:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertTrue(startItem === bStartItem, "expected \(bStartItem) at index:\(index).")
                    XCTAssertEqual(startItem.attributes!["rel"], bStartItem.attributes!["rel"], "expected \(bStartItem) at index:\(index).")
                    XCTAssertEqual(startItem.tagAttributedString.string, bStartItem.tagAttributedString.string, "expected \(bStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bStartItem) at index:\(index).")
                }
            case 8:
                if case let HTMLParsedResult.rawString(rawString) = item {
                    XCTAssertEqual(rawString.string, boldString.string, "expected \(boldString) at index:\(index).")
                } else{
                    XCTFail("expected \(boldString) at index:\(index).")
                }
            case 9:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertTrue(closeItem === bCloseItem, "expected \(bCloseItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bCloseItem) at index:\(index).")
                }
            default:
                XCTFail("unexpected result.")
            }
        }
        
    }
}
