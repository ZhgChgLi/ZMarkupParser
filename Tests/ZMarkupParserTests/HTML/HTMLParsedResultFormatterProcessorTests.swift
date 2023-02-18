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
        let hotStartItem = HTMLParsedResult.StartItem(tagName: "Hot", tagAttributedString: NSAttributedString(string: "<Hot>"), attributes: nil, token: UUID().uuidString)
        let aStartItem = HTMLParsedResult.StartItem(tagName: "a", tagAttributedString: NSAttributedString(string: "<a>"), attributes: nil, token: UUID().uuidString)
        let bStartItem = HTMLParsedResult.StartItem(tagName: "b", tagAttributedString: NSAttributedString(string: "<b rel=\"zhg\">"), attributes: ["rel":"zhg"], token: UUID().uuidString)
        let aCloseItem = HTMLParsedResult.CloseItem(tagName: "a", token: UUID().uuidString)
        let bCloseItem = HTMLParsedResult.CloseItem(tagName: "b", token: UUID().uuidString)

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
                if case let HTMLParsedResult.isolatedStart(startItem) = item {
                    XCTAssertEqual(startItem.token, hotStartItem.token, "expected \(hotStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(hotStartItem) at index:\(index).")
                }
            case 1:
                if case let HTMLParsedResult.start(startItem) = item {
                    XCTAssertEqual(startItem.token, aStartItem.token, "expected \(aStartItem) at index:\(index).")
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
                    XCTAssertEqual(startItem.token, bStartItem.token, "expected \(bStartItem) at index:\(index).")
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
                if case let HTMLParsedResult.placeholderClose(closeItem) = item {
                    XCTAssertEqual(closeItem.token, bStartItem.token, "expected \(bStartItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bStartItem) at index:\(index).")
                }
            case 6:
                if case let HTMLParsedResult.close(closeItem) = item {
                    XCTAssertEqual(closeItem.token, aCloseItem.token, "expected \(aCloseItem) at index:\(index).")
                } else{
                    XCTFail("expected \(aCloseItem) at index:\(index).")
                }
            case 7:
                if case let HTMLParsedResult.placeholderStart(startItem) = item {
                    XCTAssertEqual(startItem.token, bStartItem.token, "expected \(bStartItem) at index:\(index).")
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
                    XCTAssertEqual(closeItem.token, bCloseItem.token, "expected \(bCloseItem) at index:\(index).")
                } else{
                    XCTFail("expected \(bCloseItem) at index:\(index).")
                }
            default:
                XCTFail("unexpected result.")
            }
        }
        
    }
}
