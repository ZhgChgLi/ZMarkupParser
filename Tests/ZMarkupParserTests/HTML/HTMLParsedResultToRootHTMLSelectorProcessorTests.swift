//
//  HTMLParsedResultToRootHTMLSelectorProcessorTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/14.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLParsedResultToRootHTMLSelectorProcessorTests: XCTestCase {
    func testProcessorASTResult() {
        let rootHTMLSelector = HTMLParsedResultToRootHTMLSelectorProcessor().process(from: [
            .rawString(NSAttributedString(string: "Hello")),
            .start(.init(tagName: "b", tagAttributedString: NSAttributedString(string: "<b>"), attributes: nil)),
            .rawString(NSAttributedString(string: "Test")),
            .start(.init(tagName: "u", tagAttributedString: NSAttributedString(string: "<u>"), attributes: nil)),
            .rawString(NSAttributedString(string: "UuDd")),
            .close(.init(tagName: "u")),
            .rawString(NSAttributedString(string: "Test2")),
            .close(.init(tagName: "b")),
            .rawString(NSAttributedString(string: "World!"))
        ])
        
        // Expected AST:
        //                  rootHTMLSelector
        //          /           |           \
        //  String("Hello")   Bold     String("World!")
        //                      |
        //                      |           \          \
        //                 String("Test") Underline String("Test2")
        //                                  |
        //                              String("UuDd")
        //
        
        XCTAssertEqual(rootHTMLSelector.childSelectors.count, 3, "Expected 3 childs at root in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[0] as? HTMLTagContentSelecor)?.attributedString.string, "Hello", "Expected `Hello` child at root.childs[0] in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[1] as? HTMLTagSelecor)?.tagName, "b", "Expected `BoldMarkup` child at root.childs[1] in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[2] as? HTMLTagContentSelecor)?.attributedString.string, "World!", "Expected `World!` child at root.childs[0] in AST.")
        XCTAssertEqual(rootHTMLSelector.childSelectors[1].childSelectors.count, 3, "Expected 3 childs at root.childs[1].childs in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[1].childSelectors[0] as? HTMLTagContentSelecor)?.attributedString.string, "Test", "Expected `Test` child at root.childs[1].childs[0] in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[1].childSelectors[1] as? HTMLTagSelecor)?.tagName, "u", "Expected `UnderlineMarkup` child at root.childs[1].childs[1] in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[1].childSelectors[2] as? HTMLTagContentSelecor)?.attributedString.string, "Test2", "Expected `Test2` child at root.childs[1].childs[2] in AST.")
        XCTAssertEqual(rootHTMLSelector.childSelectors[1].childSelectors[1].childSelectors.count, 1, "Expected 1 childs at root.childs[1].childs[1].childs in AST.")
        XCTAssertEqual((rootHTMLSelector.childSelectors[1].childSelectors[1].childSelectors[0] as? HTMLTagContentSelecor)?.attributedString.string, "UuDd", "Expected `UuDd` child at root.childs[1].childs[1].childs[0] in AST.")
        XCTAssertEqual(rootHTMLSelector.attributedString.string, "HelloTestUuDdTest2World!")
    }
}
