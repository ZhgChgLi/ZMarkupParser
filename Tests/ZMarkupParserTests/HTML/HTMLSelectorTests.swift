//
//  HTMLSelectorTests.swift
//
//
//  Created by zhgchgli on 2023/3/10.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLSelectorTests: XCTestCase {
    func testFilter() {
        var compoments = MarkupIndex<HTMLElementMarkupComponent.HTMLElement>()
        let rootMarkup = RootMarkup()
        let boldMarkup = BoldMarkup()
        compoments.set(.init(tag: HTMLTag(tagName: B_HTMLTagName()), tagAttributedString: NSAttributedString(string: "<b>"), attributes: nil), for: boldMarkup)
        let underlineMarkup = UnderlineMarkup()
        compoments.set(.init(tag: HTMLTag(tagName: U_HTMLTagName()), tagAttributedString: NSAttributedString(string: "<u>"), attributes: nil), for: underlineMarkup)
        let boldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "boldText"))
        let underlineBoldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "underlineWithBoldText"))
        let rawString = RawStringMarkup(attributedString: NSAttributedString(string: "rawText"))

        underlineMarkup.appendChild(markup: underlineBoldRawString)
        boldMarkup.appendChild(markup: boldRawString)
        boldMarkup.appendChild(markup: underlineMarkup)
        rootMarkup.appendChild(markup: boldMarkup)
        rootMarkup.appendChild(markup: rawString)

        let selector = HTMLSelector(markup: rootMarkup, componets: compoments)
        XCTAssertTrue(selector.filter(B_HTMLTagName()).first?.markup === boldMarkup)
        XCTAssertTrue(selector.filter(.b).first?.markup === boldMarkup)
        XCTAssertTrue(selector.first(B_HTMLTagName())?.markup === boldMarkup)
        XCTAssertTrue(selector.first(.b)?.markup === boldMarkup)

        let dict = selector.first(.b)?.first(.u)?.get()
        XCTAssertEqual(dict?["type"] as? String, "tag")
        XCTAssertEqual(dict?["name"] as? String, "u")
        XCTAssertEqual((dict?["value"] as? NSAttributedString)?.string, "<u>")
        XCTAssertEqual((((dict?["childs"] as? [Any])?.first as? [String: Any])?["value"] as? NSAttributedString)?.string, "underlineWithBoldText")

    }
}
