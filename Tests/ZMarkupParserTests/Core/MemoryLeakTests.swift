//
//  MemoryLeakTests.swift
//
//
//  Verifies that the markup tree is released after a render pass. Originally lived in
//  `ZMarkupParserPerformanceTests`; relocated here so the standard unit-test suite covers it
//  on every CI run.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MemoryLeakTests: XCTestCase {

    private let htmlString = """
        🎄🎄🎄 <Hottest> <b>Christmas gi<u>fts</b> are here</u>! Give you more gift-giving inspiration~<br />
        The <u>final <del>countdown</del></u> on 12/9, NT$100 discount for all purchases over NT$1,000, plus a 12/12 one-day limited free shipping coupon<br>
        Top 10 Popular <b><span style="color:green">Christmas</span> Gift</b> Recommendations
        """

    func testRootMarkupIsReleasedAfterRender() {
        let parsedResult = HTMLStringToParsedResultProcessor().process(from: NSAttributedString(string: htmlString))
        let markup = HTMLParsedResultToHTMLElementWithRootMarkupProcessor(
            htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0.0) })
        ).process(from: parsedResult.items).markup

        addTeardownBlock { [weak markup] in
            XCTAssertNil(markup, "RootMarkup should have been deallocated; potential retain cycle in the markup tree.")
        }
    }

    func testZHTMLParserDoesNotRetainItsParser() {
        var parser: ZHTMLParser? = ZHTMLParserBuilder.initWithDefault().build()
        weak var weakParser = parser
        _ = parser?.render("<b>hello</b>")
        parser = nil
        XCTAssertNil(weakParser, "ZHTMLParser should be released once no strong reference remains.")
    }
}
