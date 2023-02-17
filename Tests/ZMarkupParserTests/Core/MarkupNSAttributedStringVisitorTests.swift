//
//  MarkupNSAttributedStringVisitorTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkupNSAttributedStringVisitorTests: XCTestCase {
    func testVisitMakup() {
        let rootMarkup = RootMarkup(style: MarkupStyle(kern: 99))
        let boldMarkup = BoldMarkup(style: MarkupStyle(font: MarkupStyleFont(size: 10, weight: .style(.semibold))))
        let underlineMarkup = UnderlineMarkup(style: MarkupStyle(underlineStyle: .single))
        let boldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "boldText"))
        let underlineBoldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "underlineWithBoldText"))
        let rawString = RawStringMarkup(attributedString: NSAttributedString(string: "rawText"))
        
        underlineMarkup.appendChild(markup: underlineBoldRawString)
        boldMarkup.appendChild(markup: boldRawString)
        boldMarkup.appendChild(markup: underlineMarkup)
        rootMarkup.appendChild(markup: boldMarkup)
        rootMarkup.appendChild(markup: rawString)
        
        let visitor = MarkupNSAttributedStringVisitor()
        let result = visitor.visit(rootMarkup)
        
        let underlineBoldRawStringAttributes = result.attributedSubstring(from: NSString(string: result.string).range(of: underlineBoldRawString.attributedString.string)).attributes(at: 0, effectiveRange: nil)
        
        XCTAssertEqual(underlineBoldRawStringAttributes[.kern] as? Int, rootMarkup.style?.kern?.intValue, "should set kern from rootmarkup style")
        XCTAssertEqual(underlineBoldRawStringAttributes[.underlineStyle] as? Int, underlineMarkup.style?.underlineStyle?.rawValue, "should set underlineStyle from underlineMarkup style")
        
        #if canImport(UIKit)
        if let font = underlineBoldRawStringAttributes[.font] as? UIFont {
            XCTAssertEqual(font.pointSize, 10, "should set font size from boldMarkup style")
            XCTAssertTrue((font.fontDescriptor.object(forKey: .face) as? String)?.contains("Semibold") ?? false, "should set font weight from boldMarkup style")
        }
        #elseif canImport(AppKit)
        if let font = underlineBoldRawStringAttributes[.font] as? NSFont {
            XCTAssertEqual(font.pointSize, 10, "should set font size from boldMarkup style")
            XCTAssertTrue((font.fontDescriptor.object(forKey: .face) as? String)?.contains("Semibold") ?? false, "should set font weight from boldMarkup style")
        }
        #endif
        

        
        XCTAssertEqual(result.string, "boldTextunderlineWithBoldTextrawText", "should be boldTextunderlineWithBoldTextrawText in visitor result.")
    }
}
