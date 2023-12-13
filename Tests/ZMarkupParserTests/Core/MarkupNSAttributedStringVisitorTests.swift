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
        var compoments: [MarkupStyleComponent] = []
        let rootMarkup = RootMarkup()
        let rootStyle = MarkupStyle(kern: 99)
        let boldMarkup = BoldMarkup()
        compoments.append(.init(markup: boldMarkup, value: MarkupStyle(font: MarkupStyleFont(size: 10, weight: .style(.semibold)))))
        let underlineMarkup = UnderlineMarkup()
        compoments.append(.init(markup: underlineMarkup, value: MarkupStyle(underlineStyle: .single)))
        let boldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "boldText"))
        let underlineBoldRawString = RawStringMarkup(attributedString: NSAttributedString(string: "underlineWithBoldText"))
        let rawString = RawStringMarkup(attributedString: NSAttributedString(string: "rawText"))
        
        underlineMarkup.appendChild(markup: underlineBoldRawString)
        boldMarkup.appendChild(markup: boldRawString)
        boldMarkup.appendChild(markup: underlineMarkup)
        rootMarkup.appendChild(markup: boldMarkup)
        rootMarkup.appendChild(markup: rawString)
        
        let visitor = MarkupNSAttributedStringVisitor(components: compoments, rootStyle: rootStyle)
        let result = visitor.visit(rootMarkup)
        
        let underlineBoldRawStringAttributes = result.attributedSubstring(from: NSString(string: result.string).range(of: underlineBoldRawString.attributedString.string)).attributes(at: 0, effectiveRange: nil)
        
        XCTAssertEqual(underlineBoldRawStringAttributes[.kern] as? Int, rootStyle.kern?.intValue, "should set kern from rootmarkup style")
        XCTAssertEqual(underlineBoldRawStringAttributes[.underlineStyle] as? Int, compoments.value(markup: underlineMarkup)?.underlineStyle?.rawValue, "should set underlineStyle from underlineMarkup style")
        
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
    
    func testReduceBreaklineInResultNSAttributedStringRemovePrefix() {
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let mutableAttributedString = NSMutableAttributedString(string: "\nTest")
        XCTAssertEqual(visitor.reduceBreaklineInResultNSAttributedString(mutableAttributedString).string, "\nTest", "Shoud only remove break line with attritube:reduceableBreakLine")
        
        
        mutableAttributedString.addAttributes([.reduceableBreakLine: true], range: NSMakeRange(0, 1))
        XCTAssertEqual(visitor.reduceBreaklineInResultNSAttributedString(mutableAttributedString).string, "Test", "Shoud remove break line with attritube:reduceableBreakLine")
    }
    
    func testReduceBreaklineInResultNSAttributedStringRemoveSuffix() {
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let mutableAttributedString = NSMutableAttributedString(string: "Test\n")
        XCTAssertEqual(visitor.reduceBreaklineInResultNSAttributedString(mutableAttributedString).string, "Test\n", "Shoud only remove break line with attritube:reduceableBreakLine")
        
        
        mutableAttributedString.addAttributes([.reduceableBreakLine: true], range: NSMakeRange(mutableAttributedString.length - 1, 1))
        XCTAssertEqual(visitor.reduceBreaklineInResultNSAttributedString(mutableAttributedString).string, "Test", "Shoud remove break line with attritube:reduceableBreakLine")
    }
    
    func testReduceBreaklineInResultNSAttributedStringRemoveReduntantBreakLine() {
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: "\n\n\n\n\n", attributes: [.reduceableBreakLine: true]))
        mutableAttributedString.append(NSAttributedString(string: "\nTTTT\n\n")) // origin break line should not remove
        mutableAttributedString.append(NSAttributedString(string: "AAAA\n\n", attributes: [.reduceableBreakLine: false])) // false reduceableBreakLine break line should not remove
        
        mutableAttributedString.append(NSAttributedString(string: "\n\n\n\n\n", attributes: [.reduceableBreakLine: true])) // true reduceableBreakLine break line should replace to one \n
        mutableAttributedString.append(NSAttributedString(string: "BBBB"))
        mutableAttributedString.append(NSAttributedString(string: "\n\n", attributes: [.reduceableBreakLine: true]))
        mutableAttributedString.append(NSAttributedString(string: "DDD"))
        mutableAttributedString.append(NSAttributedString(string: "\n\n\n\n\n", attributes: [.reduceableBreakLine: true]))
        mutableAttributedString.append(NSAttributedString(string: "CCCC\n"))
        mutableAttributedString.append(NSAttributedString(string: "\n\n\n\n\n", attributes: [.reduceableBreakLine: true]))
        
        let result = visitor.reduceBreaklineInResultNSAttributedString(mutableAttributedString).string
        XCTAssertEqual(result, "\nTTTT\n\nAAAA\n\n\nBBBB\nDDD\nCCCC\n", "Shoud only remove break line with attritube:reduceableBreakLine")
    }
    
    func testApplyMarkupStyle() {
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let result = visitor.applyMarkupStyle(NSAttributedString(string: "Test"), with: MarkupStyle(kern: 999))
        
        XCTAssertEqual(result.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 999)
    }
}

private extension NSAttributedString.Key {
    static let reduceableBreakLine: NSAttributedString.Key = .init("reduceableBreakLine")
}
private extension NSAttributedString.Key {
    static let isBreakLine: NSAttributedString.Key = .init("isBreakLine")
}
