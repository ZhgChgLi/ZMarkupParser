//
//  HTMLParsedResultToHTMLElementWithRootMarkupProcessorTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLParsedResultToHTMLElementWithRootMarkupProcessorTests: XCTestCase {
    func testProcessor() {
        let result = HTMLParsedResultToHTMLElementWithRootMarkupProcessor(htmlTags: ZHTMLParserBuilder.htmlTagNames.map({ HTMLTag(tagName: $0) })).process(from: [
            .rawString(NSAttributedString(string: "Hello")),
            .start(.init(tagName: "i", tagAttributedString: NSAttributedString(string: "<i>"), attributes: nil)),
            .rawString(NSAttributedString(string: "Test")),
            .selfClosing(.init(tagName: "br", tagAttributedString: NSAttributedString(string: "<br/>"), attributes: nil)),
            .start(.init(tagName: "u", tagAttributedString: NSAttributedString(string: "<u>"), attributes: nil)),
            .rawString(NSAttributedString(string: "UuDd")),
            .close(.init(tagName: "u")),
            .rawString(NSAttributedString(string: "Test2")),
            .close(.init(tagName: "i")),
            .rawString(NSAttributedString(string: "World!"))
        ])
        
        // Expected AST:
        //                  rootMarkup
        //          /           |           \
        //  String("Hello")   Bold     String("World!")
        //                      |
        //          /           |           \          \
        //   String("Test") BreakLine   Underline String("Test2")
        //                                  |
        //                              String("UuDd")
        //
        
        XCTAssertEqual(result.markup.childMarkups.count, 3, "Expected 3 childs at root in AST.")
        XCTAssertEqual((result.markup.childMarkups[0] as? RawStringMarkup)?.attributedString.string, "Hello", "Expected `Hello` child at root.childs[0] in AST.")
        XCTAssertTrue(result.markup.childMarkups[1] is ItalicMarkup, "Expected `ItalicMarkup` child at root.childs[1] in AST.")
        XCTAssertEqual((result.markup.childMarkups[2] as? RawStringMarkup)?.attributedString.string, "World!", "Expected `World!` child at root.childs[0] in AST.")
        XCTAssertEqual(result.markup.childMarkups[1].childMarkups.count, 4, "Expected 4 childs at root.childs[1].childs in AST.")
        XCTAssertEqual((result.markup.childMarkups[1].childMarkups[0] as? RawStringMarkup)?.attributedString.string, "Test", "Expected `Test` child at root.childs[1].childs[0] in AST.")
        XCTAssertTrue(result.markup.childMarkups[1].childMarkups[1] is BreakLineMarkup, "Expected `BreakLineMarkup` child at root.childs[1].childs[1] in AST.")
        XCTAssertTrue(result.markup.childMarkups[1].childMarkups[2] is UnderlineMarkup, "Expected `UnderlineMarkup` child at root.childs[1].childs[2] in AST.")
        XCTAssertEqual((result.markup.childMarkups[1].childMarkups[3] as? RawStringMarkup)?.attributedString.string, "Test2", "Expected `Test2` child at root.childs[1].childs[3] in AST.")
        XCTAssertEqual(result.markup.childMarkups[1].childMarkups[2].childMarkups.count, 1, "Expected 1 childs at root.childs[1].childs[2].childs in AST.")
        XCTAssertEqual((result.markup.childMarkups[1].childMarkups[2].childMarkups[0] as? RawStringMarkup)?.attributedString.string, "UuDd", "Expected `UuDd` child at root.childs[1].childs[2].childs[0] in AST.")
    }
}
