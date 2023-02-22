//
//  MarkupStyleTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
@testable import ZMarkupParser
import XCTest

// ToDo: test all MarkupStyle attribute
final class MarkupStyleTests: XCTestCase {
    func testFillIfNil_has_respect_current() {
        var current = MarkupStyle(kern: 999)
        let from = MarkupStyle(kern: 1000)
        
        current.fillIfNil(from: from)
        XCTAssertEqual(current.kern, 999, "MarkupStyle only fill from if nil.")
    }
    
    func testFillIfNil_has_fill_if_nil() {
        var current = MarkupStyle(kern: nil)
        let from = MarkupStyle(kern: 1000)
        
        current.fillIfNil(from: from)
        XCTAssertEqual(current.kern, 1000, "MarkupStyle should fill from if nil.")
    }
    
    func testFillIfNil_with_font() {
        var current = MarkupStyle(font: MarkupStyleFont(size: 10, italic: nil))
        let from = MarkupStyle(font: MarkupStyleFont(size: 999, italic: true))
        
        current.fillIfNil(from: from)
        XCTAssertEqual(current.font.size, 10, "MarkupStyle.font only fill from if nil.")
        XCTAssertEqual(current.font.italic, true, "MarkupStyle.italic should fill from if nil.")
    }
    
    func testRender() {
        let style = MarkupStyle(font: MarkupStyleFont(size: 10, weight: .style(.semibold), italic: true), kern: 99, strikethroughStyle: .single, underlineStyle: .single, link: URL(string: "https://zhgchg.li")!)
        
        let attributes = style.render()
        
        XCTAssertEqual(attributes[.kern] as? Int, 99, "markup style should convert kern setting.")
        
        #if canImport(UIKit)
        if let font = attributes[.font] as? UIFont {
            XCTAssertEqual(font.pointSize, 10, "markup style should convert font size setting.")
            XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.traitItalic), "markup style should convert font italic setting.")
            XCTAssertTrue((font.fontDescriptor.object(forKey: .face) as? String)?.contains("Semibold") ?? false, "markup style should convert font weight setting.")
        } else {
            XCTFail("markup style should convert font setting.")
        }
        #elseif canImport(AppKit)
        if let font = attributes[.font] as? NSFont {
            XCTAssertEqual(font.pointSize, 10, "markup style should convert font size setting.")
            XCTAssertTrue(font.fontDescriptor.symbolicTraits.contains(.italic), "markup style should convert font italic setting.")
            XCTAssertTrue((font.fontDescriptor.object(forKey: .face) as? String)?.contains("Bold") ?? false, "markup style should convert font weight setting.")
        } else {
            XCTFail("markup style should convert font setting.")
        }
        #endif

        
        XCTAssertEqual(attributes[.underlineStyle] as? Int, style.underlineStyle?.rawValue, "markup style should convert underlineStyle setting.")
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, style.strikethroughStyle?.rawValue, "markup style should convert strikethroughStyle setting.")
        XCTAssertEqual(attributes[.link] as? URL, style.link, "markup style should convert strikethroughStyle setting.")
    }
    
    func testNSParagraphStyleShoudBeNilIfNotSet() {
        let markupStyle = MarkupStyle()
        XCTAssertTrue(markupStyle.render().isEmpty, "Default init MarkupStyle() should be empty")
    }
}
