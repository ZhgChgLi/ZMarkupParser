//
//  HTMLSelectorToMarkupProcessorTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLSelectorToMarkupProcessorTests: XCTestCase {
    func testProcessor() {
        let processor = HTMLSelectorToMarkupProcessor(rootStyle: MarkupStyle(kern: 999), htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0) }), styleAttributes: ZHTMLParserBuilder.styleAttributes)
        let rootSelector = RootHTMLSelecor()
        rootSelector.appendChild(selector: RawStringSelecor(attributedString: NSAttributedString(string: "Test")))
        let aSelector = HTMLTagSelecor(tagName: "a", tagAttributedString: NSAttributedString(string: "<a>"), attributes: nil)
        rootSelector.appendChild(selector: aSelector)
        aSelector.appendChild(selector: RawStringSelecor(attributedString: NSAttributedString(string: "Test2")))
        let uSelector = HTMLTagSelecor(tagName: "u", tagAttributedString: NSAttributedString(string: "<u>"), attributes: nil)
        aSelector.appendChild(selector: uSelector)
        uSelector.appendChild(selector: RawStringSelecor(attributedString: NSAttributedString(string: "Test3")))
        rootSelector.appendChild(selector: RawStringSelecor(attributedString: NSAttributedString(string: "Test4")))
        
        let rootMarkup = processor.process(from: rootSelector)
        
        // Expected AST:
        //                  rootMarkup
        //          /           |           \
        //  String("Test")    Link     String("Test4")
        //                      |
        //          /           |
        //   String("Test2") Underline
        //                      |
        //                   String("Test3")
        //
        
        XCTAssertEqual(rootMarkup.childMarkups.count, 3, "Expected 3 childs at root in AST.")
        XCTAssertEqual((rootMarkup.childMarkups[0] as? RawStringMarkup)?.attributedString.string, "Test", "Expected `Test` child at root.childs[0] in AST.")
        XCTAssertTrue(rootMarkup.childMarkups[1] is LinkMarkup, "Expected `LinkMarkup` child at root.childs[1] in AST.")
        XCTAssertEqual((rootMarkup.childMarkups[2] as? RawStringMarkup)?.attributedString.string, "Test4", "Expected `Test4` child at root.childs[0] in AST.")
        XCTAssertEqual(rootMarkup.childMarkups[1].childMarkups.count, 2, "Expected 2 childs at root.childs[1].childs in AST.")
        XCTAssertEqual((rootMarkup.childMarkups[1].childMarkups[0] as? RawStringMarkup)?.attributedString.string, "Test2", "Expected `Test2` child at root.childs[1].childs[0] in AST.")
        XCTAssertTrue(rootMarkup.childMarkups[1].childMarkups[1] is UnderlineMarkup, "Expected `UnderlineMarkup` child at root.childs[1].childs[1] in AST.")
        XCTAssertEqual(rootMarkup.childMarkups[1].childMarkups[1].childMarkups.count, 1, "Expected 1 childs at root.childs[1].childs[1].childs in AST.")
        XCTAssertEqual((rootMarkup.childMarkups[1].childMarkups[1].childMarkups[0] as? RawStringMarkup)?.attributedString.string, "Test3", "Expected `Test4` child at root.childMarkups[1].childMarkups[1].childMarkups[0] in AST.")
    }
}
