//
//  HTMLSelectorTests.swift
//  
//
//  Created by zhgchgli on 2023/2/25.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLSelectorTests: XCTestCase {
    func testSelectorFirst() {
        let rawStringSelector = RawStringSelecor(attributedString: NSAttributedString(string: "test"))
        let aSelector = HTMLTagSelecor(tagName: "a", tagAttributedString: NSAttributedString(string: "<a>"), attributes: nil)
        let bSelector = HTMLTagSelecor(tagName: "b", tagAttributedString: NSAttributedString(string: "<b>"), attributes: nil)
        let uSelector = HTMLTagSelecor(tagName: "u", tagAttributedString: NSAttributedString(string: "<u>"), attributes: nil)
        let rootSelector = RootHTMLSelecor()
    
        rootSelector.appendChild(selector: aSelector)
        aSelector.appendChild(selector: bSelector)
        aSelector.appendChild(selector: uSelector)
        uSelector.appendChild(selector: rawStringSelector)
        
        XCTAssertEqual(rootSelector.first(.a)?.tagName, aSelector.tagName, "Should filter tag a.")
        XCTAssertEqual(rootSelector.first(A_HTMLTagName())?.tagName, aSelector.tagName, "Should filter tag a.")
        XCTAssertEqual(rootSelector.first("a")?.tagName, aSelector.tagName, "Should filter tag a.")
        XCTAssertEqual(rootSelector.first("a")?.first("u")?.attributedString.string, "test", "attributedString should be test.")
    }
}
