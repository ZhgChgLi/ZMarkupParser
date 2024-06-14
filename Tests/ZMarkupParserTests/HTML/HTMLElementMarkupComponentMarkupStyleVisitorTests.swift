//
//  HTMLElementMarkupComponentMarkupStyleVisitorTests.swift
//  
//
//  Created by zhgchgli on 2023/7/23.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class HTMLElementMarkupComponentMarkupStyleVisitorTests: XCTestCase {

    func testDefaultStyleByDefault() {
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromCode, components: [], styleAttributes: [], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: HeadMarkup(level: .h1))
        XCTAssertEqual(result?.font.size, MarkupStyle.h1.font.size)
    }
    
    func testDefaultStyleByCustomStyle() {
        let markup = InlineMarkup()
        let customStyle = MarkupStyle(font: .init(size: 99))
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromCode, components: [.init(markup: markup, value: .init(tag: .init(tagName: H1_HTMLTagName(), customStyle: customStyle), tagAttributedString: NSAttributedString(string: "<span>test</span>"), attributes: [:]))], styleAttributes: [], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: markup)
        XCTAssertEqual(result?.font.size, customStyle.font.size)
    }
    
    func testDefaultStyleShouldOverrideByCustomStyle() {
        let markup = HeadMarkup(level: .h1)
        let customStyle = MarkupStyle(font: .init(size: 99))
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromCode, components: [.init(markup: markup, value: .init(tag: .init(tagName: H1_HTMLTagName(), customStyle: customStyle), tagAttributedString: NSAttributedString(string: "<h1>test</h1>"), attributes: [:]))], styleAttributes: [], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: markup)
        XCTAssertEqual(result?.font.size, customStyle.font.size)
    }
    
    func testDefaultStyleShouldOverrideByStyleAttributed() {
        let markup = HeadMarkup(level: .h1)
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromCode, components: [.init(markup: markup, value: .init(tag: .init(tagName: H1_HTMLTagName()), tagAttributedString: NSAttributedString(string: "<h1>test</h1>"), attributes: ["style": "font-size:99pt"]))], styleAttributes: [FontSizeHTMLTagStyleAttribute()], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: markup)
        XCTAssertEqual(result?.font.size, 99)
    }
    
    func testDefaultStylePolicyRespectMarkupStyleFromCode() {
        let markup = HeadMarkup(level: .h1)
        let customStyle = MarkupStyle(font: .init(size: 109))
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromCode, components: [.init(markup: markup, value: .init(tag: .init(tagName: H1_HTMLTagName(), customStyle: customStyle), tagAttributedString: NSAttributedString(string: "<h1>test</h1>"), attributes: ["style": "font-size:99pt"]))], styleAttributes: [FontSizeHTMLTagStyleAttribute()], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: markup)
        XCTAssertEqual(result?.font.size, customStyle.font.size)
    }
    
    func testDefaultStylePolicyRespectMarkupStyleFromHTMLStyleAttribute() {
        let markup = HeadMarkup(level: .h1)
        let customStyle = MarkupStyle(font: .init(size: 109))
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: .respectMarkupStyleFromHTMLStyleAttribute, components: [.init(markup: markup, value: .init(tag: .init(tagName: H1_HTMLTagName(), customStyle: customStyle), tagAttributedString: NSAttributedString(string: "<h1>test</h1>"), attributes: ["style": "font-size:99pt"]))], styleAttributes: [FontSizeHTMLTagStyleAttribute()], classAttributes: [], idAttributes: [], rootStyle: nil)
        
        let result = visitor.visit(markup: markup)
        XCTAssertEqual(result?.font.size, 99)
    }
}
