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

    private let parser = ZHTMLParser(htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0.0) }), styleAttributes: ZHTMLParserBuilder.styleAttributes, classAttributes: [], idAttributes: [], policy: .respectMarkupStyleFromCode, rootStyle: MarkupStyle(kern: 999))

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
    
    func testRenderShouldKeepExistsAttribute() {
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "Test"))
        attributedString.append(NSAttributedString(string: "<a href=\"https://zhgchg.li\">"))
        attributedString.append(NSAttributedString(string: "Qoo"))
        attributedString.append(NSAttributedString(string: "DDD", attributes: [.baselineOffset: 10]))
        attributedString.append(NSAttributedString(string: "</a>oog"))
        
        let renderResult = parser.render(attributedString)
        
        XCTAssertEqual(renderResult.attributedSubstring(from: NSString(string: renderResult.string).range(of: "QooDDD")).attributes(at: 0, effectiveRange: nil)[.link] as? URL, URL(string: "https://zhgchg.li"))
        XCTAssertEqual(renderResult.attributedSubstring(from: NSString(string: renderResult.string).range(of: "DDD")).attributes(at: 0, effectiveRange: nil)[.baselineOffset] as? Int, 10)
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
    
    func testRenderWithHTMLEntities() {
        let attributedString = NSAttributedString(string: "My favorite emoji is &#x1F643;, &lt;a href=\"https://zhgchg.li\"&gt;link&lt;/a&gt;")
        let renderResult = parser.render(attributedString, forceDecodeHTMLEntities: true)
        
        XCTAssertEqual(renderResult.attributedSubstring(from: NSString(string: renderResult.string).range(of: "link")).attributes(at: 0, effectiveRange: nil)[.link] as? URL, URL(string: "https://zhgchg.li"))
        XCTAssertEqual(renderResult.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 999)
    }
    
    func testRenderWithoutHTMLEntities() {
        let attributedString = NSAttributedString(string: "My favorite emoji is &#x1F643;, &lt;a href=\"https://zhgchg.li\"&gt;link&lt;/a&gt;")
        let renderResult = parser.render(attributedString, forceDecodeHTMLEntities: false)
        
        XCTAssertEqual(renderResult.string, attributedString.string)
        XCTAssertEqual(renderResult.attributes(at: 0, effectiveRange: nil).count, 1)
        XCTAssertEqual(renderResult.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 999)
    }
    
    func testDecodeHTMLEntities() {
        let string = "My favorite emoji is &#x1F643;, &lt;a&gt;link&lt;/a&gt;"
        let result = parser.decodeHTMLEntities(string)

        XCTAssertEqual(result, "My favorite emoji is 🙃, <a>link</a>")

        let attributedString = NSAttributedString(string: "My favorite emoji is &#x1F643;, &lt;a&gt;link&lt;/a&gt;", attributes: [.kern: 100])
        let result2 = parser.decodeHTMLEntities(attributedString)

        XCTAssertEqual(result2.string, "My favorite emoji is 🙃, <a>link</a>")
        XCTAssertEqual(result2.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 100)
    }

    /// Hammers `render(_:)` from many threads against the same parser to flush out races on the
    /// shared processors, the static regex cache (`ParserRegexr.cachedExpression`) and the
    /// per-process style precompute. All concurrent renders must produce the exact same result
    /// as the single-threaded reference render.
    func testConcurrentRenderProducesIdenticalResults() {
        let html = "🎄 <Hottest> <b>Christmas <u>gift</b>s</u> are here<br/><a href=\"https://zhgchg.li\">link</a>!"
        let referencePlain = parser.render(html).string
        XCTAssertFalse(referencePlain.isEmpty)

        let iterations = 200
        let expectation = XCTestExpectation(description: #function)
        expectation.expectedFulfillmentCount = iterations
        let queue = DispatchQueue.global(qos: .userInitiated)
        let lock = NSLock()
        var mismatches: [String] = []

        for _ in 0..<iterations {
            queue.async {
                let resultPlain = self.parser.render(html).string
                if resultPlain != referencePlain {
                    lock.lock()
                    mismatches.append(resultPlain)
                    lock.unlock()
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 30.0)
        XCTAssertTrue(mismatches.isEmpty, "concurrent renders must match the reference plain text; got \(mismatches.count) mismatches")
    }

    func testConcurrentSelectorAndStripperAreThreadSafe() {
        let html = "<div><a href=\"https://zhgchg.li\">L<b>i</b>nk</a><p>P<u>ar</u>a</p></div>"
        let referenceSelector = parser.selector(html).first("a")?.attributedString.string
        let referenceStripper = parser.stripper(html)

        let iterations = 200
        let expectation = XCTestExpectation(description: #function)
        expectation.expectedFulfillmentCount = iterations
        let queue = DispatchQueue.global(qos: .userInitiated)
        let lock = NSLock()
        var failures = 0

        for i in 0..<iterations {
            queue.async {
                if i.isMultiple(of: 2) {
                    let selectorResult = self.parser.selector(html).first("a")?.attributedString.string
                    if selectorResult != referenceSelector {
                        lock.lock(); failures += 1; lock.unlock()
                    }
                } else {
                    let stripperResult = self.parser.stripper(html)
                    if stripperResult != referenceStripper {
                        lock.lock(); failures += 1; lock.unlock()
                    }
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 30.0)
        XCTAssertEqual(failures, 0, "concurrent selector/stripper must match the reference results")
    }
}
