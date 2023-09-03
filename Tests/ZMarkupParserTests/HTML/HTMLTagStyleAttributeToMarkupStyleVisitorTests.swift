//
//  HTMLTagStyleAttributeToMarkupStyleVisitorTests.swift
//  
//
//  Created by zhgchgli on 2023/7/23.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLTagStyleAttributeToMarkupStyleVisitorTests: XCTestCase {
    func testConvert() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "test")
        
        
        XCTAssertEqual(visitor.convert(fromPX: "14px"), 14)
        XCTAssertEqual(visitor.convert(fromPX: "14pt"), 14)
    }
    
    func testColorHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "#ff0000")
        let markupStyle = visitor.visit(ColorHTMLTagStyleAttribute())
        
        XCTAssertEqual(markupStyle?.foregroundColor?.red, MarkupStyleColor(string: "#ff0000")?.red)
        XCTAssertEqual(markupStyle?.foregroundColor?.green, MarkupStyleColor(string: "#ff0000")?.green)
        XCTAssertEqual(markupStyle?.foregroundColor?.blue, MarkupStyleColor(string: "#ff0000")?.blue)
        XCTAssertEqual(markupStyle?.foregroundColor?.alpha, MarkupStyleColor(string: "#ff0000")?.alpha)
    }
    
    func testBackgroundColorHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "#ff0000")
        let markupStyle = visitor.visit(BackgroundColorHTMLTagStyleAttribute())
        
        XCTAssertEqual(markupStyle?.backgroundColor?.red, MarkupStyleColor(string: "#ff0000")?.red)
        XCTAssertEqual(markupStyle?.backgroundColor?.green, MarkupStyleColor(string: "#ff0000")?.green)
        XCTAssertEqual(markupStyle?.backgroundColor?.blue, MarkupStyleColor(string: "#ff0000")?.blue)
        XCTAssertEqual(markupStyle?.backgroundColor?.alpha, MarkupStyleColor(string: "#ff0000")?.alpha)
    }
    
    func testFontSizeHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "16px")
        let markupStyle = visitor.visit(FontSizeHTMLTagStyleAttribute())
        
        XCTAssertEqual(markupStyle?.font.size, 16)
    }
    
    func testLineHeightHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "16px")
        let markupStyle = visitor.visit(LineHeightHTMLTagStyleAttribute())
        
        XCTAssertEqual(markupStyle?.paragraphStyle.maximumLineHeight, 16)
        XCTAssertEqual(markupStyle?.paragraphStyle.minimumLineHeight, 16)
    }
    
    func testWordSpacingHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "16px")
        let markupStyle = visitor.visit(WordSpacingHTMLTagStyleAttribute())
        
        XCTAssertEqual(markupStyle?.paragraphStyle.lineSpacing, 16)
    }
    
    func testFontWeightHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "bold")
        let markupStyle = visitor.visit(FontWeightHTMLTagStyleAttribute())
        
        if case let .style(weight) = markupStyle?.font.weight, weight == .bold {
            // Success
        } else {
            XCTFail()
        }
    }
    
    func testFontWeightHTMLTagStyleAttribute2() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "500")
        let markupStyle = visitor.visit(FontWeightHTMLTagStyleAttribute())
        
        if case let .style(style) = markupStyle?.font.weight, style == .medium {
            // Success
        } else {
            XCTFail()
        }
    }

    func testFontWeightHTMLTagStyleAttribute3() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "501")
        let markupStyle = visitor.visit(FontWeightHTMLTagStyleAttribute())
        
        if case let .rawValue(weight) = markupStyle?.font.weight, weight == 501 {
            // Success
        } else {
            XCTFail()
        }
    }
    
    func testFontFamilyHTMLTagStyleAttribute() {
        let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: "'Times New Roman', Times, serif")
        let markupStyle = visitor.visit(FontFamilyHTMLTagStyleAttribute())
        
        if case let .familyNames(familyNames) = markupStyle?.font.familyName, familyNames.count == 3 {
            // Success
            XCTAssertEqual(familyNames[0], "Times New Roman")
            XCTAssertEqual(familyNames[1], "Times")
            XCTAssertEqual(familyNames[2], "serif")
        } else {
            XCTFail()
        }
    }
}
