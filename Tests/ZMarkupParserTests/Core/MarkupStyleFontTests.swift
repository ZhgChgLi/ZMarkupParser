//
//  MarkupStyleFontTests.swift
//  
//
//  Created by zhgchgli on 2023/8/3.
//

import Foundation
@testable import ZMarkupParser
import XCTest
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

final class MarkupStyleFontTests: XCTestCase {
    func testInit() {
        #if canImport(UIKit)
            let markupStyleFont = MarkupStyleFont(UIFont.systemFont(ofSize: 16, weight: .bold))
            if case let .style(weight) = markupStyleFont.weight, weight == .bold {
                 // Success
                XCTAssertEqual(markupStyleFont.size, 16)
             } else {
                XCTFail()
             }
        #elseif canImport(AppKit)
            let markupStyleFont = MarkupStyleFont(NSFont.boldSystemFont(ofSize: 16))
            if case let .style(weight) = markupStyleFont.weight, weight == .bold {
                 // Success
                XCTAssertEqual(markupStyleFont.size, 16)
             } else {
                XCTFail()
             }
        #endif
    }
    
    func testIsNil() {
        var markupStyleFont = MarkupStyleFont()
        XCTAssertTrue(markupStyleFont.isNil())
        
        markupStyleFont = MarkupStyleFont()
        markupStyleFont.size = 16
        XCTAssertFalse(markupStyleFont.isNil())
        
        markupStyleFont = MarkupStyleFont()
        markupStyleFont.italic = true
        XCTAssertFalse(markupStyleFont.isNil())
        
        markupStyleFont = MarkupStyleFont()
        markupStyleFont.weight = .style(.bold)
        XCTAssertFalse(markupStyleFont.isNil())
        
        markupStyleFont = MarkupStyleFont()
        markupStyleFont.familyName = .familyNames(["Times"])
        XCTAssertFalse(markupStyleFont.isNil())
    }
    
    func testFontFamily() {
        let fontWeightStyle = MarkupStyleFont.FontFamily.familyNames(["Times New Roman", "Times", "serif"])
        #if canImport(UIKit)
            let font = fontWeightStyle.getFont(size: 16)
            XCTAssertEqual(font?.familyName, "Times New Roman")
            XCTAssertEqual(font?.pointSize, 16)
        #elseif canImport(AppKit)
            let font = fontWeightStyle.getFont(size: 16)
            XCTAssertEqual(font?.familyName, "Times New Roman")
            XCTAssertEqual(font?.pointSize, 16)
        #endif
    }
    
    func testFontFamily2() {
        let fontWeightStyle = MarkupStyleFont.FontFamily.familyNames(["Invaild Font", "Times New Roman", "Times", "serif"])
        #if canImport(UIKit)
            let font = fontWeightStyle.getFont(size: 16)
            XCTAssertEqual(font?.familyName, "Times New Roman")
            XCTAssertEqual(font?.pointSize, 16)
        #elseif canImport(AppKit)
            let font = fontWeightStyle.getFont(size: 16)
            XCTAssertEqual(font?.familyName, "Times New Roman")
            XCTAssertEqual(font?.pointSize, 16)
        #endif
    }
    
    func testCustomFontSizeAndBoldAndItalic() {
        // with Custom Font, >= Medium, than bold
        var markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.medium), italic: true, familyName: .familyNames(["Helvetica"]))
        var resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .bold)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(resultMarkupStyleFont.familyName?.getFont(size: markupStyleFont.size!)?.fontName, "Helvetica")
        
        // with Custom Font, < Medium, than no bold
        markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.regular), italic: true, familyName: .familyNames(["Helvetica"]))
        resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        XCTAssertNil(resultMarkupStyleFont.weight)
        XCTAssertEqual(resultMarkupStyleFont.familyName?.getFont(size: markupStyleFont.size!)?.fontName, "Helvetica")
    }
    
    func testSystemFontSizeAndBoldAndItalic() {
        
        var markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.medium), italic: true)
        var resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .medium)
        } else {
            XCTFail()
        }
        
        markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.regular), italic: true)
        resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .regular)
        } else {
            XCTFail()
        }
    }
    
    func testCustomFontSizeAndBold() {
        // with Custom Font, >= Medium, than bold
        var markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.medium), italic: nil, familyName: .familyNames(["Helvetica"]))
        var resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .bold)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(resultMarkupStyleFont.familyName?.getFont(size: markupStyleFont.size!)?.fontName, "Helvetica")
        
        // with Custom Font, < Medium, than no bold
        markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.regular), italic: nil, familyName: .familyNames(["Helvetica"]))
        resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .regular)
        } else {
            XCTFail()
        }
        XCTAssertEqual(resultMarkupStyleFont.familyName?.getFont(size: markupStyleFont.size!)?.fontName, "Helvetica")
    }
    
    func testSystemFontSizeAndBold() {
        var markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.heavy))
        var resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .heavy)
        } else {
            XCTFail()
        }
        
        markupStyleFont = MarkupStyleFont(size: 99, weight: .style(.regular))
        resultMarkupStyleFont = MarkupStyleFont(markupStyleFont.getFont()!)
        
        XCTAssertEqual(resultMarkupStyleFont.size, markupStyleFont.size!)
        if case let .style(weight) = resultMarkupStyleFont.weight {
            XCTAssertEqual(weight, .regular)
        } else {
            XCTFail()
        }
    }
}
