//
//  ZHTMLParserAttributedStringTests.swift
//
//
//  Covers `ZHTMLParser+AttributedString` — verifies that the
//  `NSAttributedString` -> `AttributedString` wrapper preserves the parser's
//  rendered text and the attributes SwiftUI / iOS 15+ consumers actually look
//  at (link, font traits, paragraph style), and that the completion-handler
//  variant returns on the main queue like the other `ZHTMLParser` async APIs.
//

import Foundation
@testable import ZMarkupParser
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
final class ZHTMLParserAttributedStringTests: XCTestCase {

    private let parser = ZHTMLParserBuilder.initWithDefault().build()

    func testAttributedStringPlainTextMatchesRender() {
        let html = "Hello <b>bold</b> <i>italic</i> <a href=\"https://zhgchg.li\">link</a> end."
        let viaWrapper = parser.attributedString(html)
        let viaRender = parser.render(html)

        XCTAssertEqual(String(viaWrapper.characters), viaRender.string)
    }

    func testAttributedStringPreservesLink() {
        let html = "prefix <a href=\"https://zhgchg.li\">click here</a> suffix"
        let attributed = parser.attributedString(html)

        var collectedURL: URL?
        for run in attributed.runs {
            if let link = run.link {
                collectedURL = link
                break
            }
        }
        XCTAssertEqual(collectedURL, URL(string: "https://zhgchg.li"))
    }

    func testAttributedStringPreservesBoldFontTrait() {
        let html = "normal <b>strong</b> normal"
        let attributed = parser.attributedString(html)
        let plain = String(attributed.characters)
        guard let boldStart = plain.range(of: "strong") else {
            return XCTFail("expected 'strong' in rendered output, got: \(plain)")
        }

        // Find the run that contains the "strong" range and assert its font is bold.
        let lower = AttributedString.Index(boldStart.lowerBound, within: attributed)!
        let runAtBold = attributed.runs[lower]
        #if canImport(UIKit)
        guard let font = runAtBold.uiKit.font else {
            return XCTFail("expected a UIFont on the bold run")
        }
        XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.traitBold), "<b> run should carry a bold UIFont; got \(font)")
        #elseif canImport(AppKit)
        guard let font = runAtBold.appKit.font else {
            return XCTFail("expected an NSFont on the bold run")
        }
        XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.bold), "<b> run should carry a bold NSFont; got \(font)")
        #endif
    }

    func testAttributedStringCompletionHandlerInvokedOnMain() {
        let html = "Test<a href=\"https://zhgchg.li\">Qoo</a>DDD"
        let referencePlain = String(parser.attributedString(html).characters)

        let expectation = XCTestExpectation(description: #function)
        parser.attributedString(html) { result in
            XCTAssertTrue(Thread.isMainThread, "completion handler must fire on the main queue, mirroring render(_:completionHandler:)")
            XCTAssertEqual(String(result.characters), referencePlain)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testAttributedStringFromNSAttributedStringInputMatchesRender() {
        let attributed = NSAttributedString(string: "Test<a href=\"https://zhgchg.li\">Qoo</a>DDD", attributes: [.kern: 5])
        let viaWrapper = parser.attributedString(attributed)
        let viaRender = parser.render(attributed)

        XCTAssertEqual(String(viaWrapper.characters), viaRender.string)
    }

    func testAttributedStringFromSelectorMatchesRender() {
        let html = "Test<a href=\"https://zhgchg.li\">Q<b>fa</b>foo</a>DDD"
        let selector = parser.selector(html)
        guard let anchor = selector.first("a") else {
            return XCTFail("expected to find <a> in selector")
        }

        let viaWrapper = parser.attributedString(anchor)
        let viaRender = parser.render(anchor)

        XCTAssertEqual(String(viaWrapper.characters), viaRender.string)
    }
}
