//
//  ZHTMLParserBuilderTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/18.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class ZHTMLParserBuilderTests: XCTestCase {
    func testSetRootStyle() {
        let markupStyle = MarkupStyle(kern: 9999)
        let builder = ZHTMLParserBuilder().set(rootStyle: markupStyle)
        XCTAssertEqual(builder.rootStyle?.kern, 9999, "\(markupStyle) should be set as rootStyle.")
    }
    
    func testAddTagName() {
        let markupStyle = MarkupStyle(kern: 9999)
        var builder = ZHTMLParserBuilder()
        XCTAssertEqual(builder.htmlTags.count, 0, "htmlTags should be empty after init.")
        builder = builder.add(ExtendTagName("zhgchgli"), withCustomStyle: markupStyle)
        XCTAssertEqual(builder.htmlTags.count, 1, "htmlTags should have 1 element.")
        XCTAssertEqual(builder.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element.")
        XCTAssertEqual(builder.htmlTags[0].customStyle?.kern, 9999, "zhgchgli tag name element should have custome style.")
    }
    
    func testSetTagName() {
        let markupStyle = MarkupStyle(kern: 9999)
        var builder = ZHTMLParserBuilder()
        XCTAssertEqual(builder.htmlTags.count, 0, "htmlTags should be empty after init.")
        builder = builder.set(ExtendTagName("zhgchgli"), withCustomStyle: markupStyle)
        XCTAssertEqual(builder.htmlTags.count, 1, "htmlTags should have 1 element.")
        XCTAssertEqual(builder.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element.")
        XCTAssertEqual(builder.htmlTags[0].customStyle?.kern, 9999, "zhgchgli tag name element should have custome style.")
    }
    
    func testAddSetTagNameIfTagNameExists() {
        
        var builder = ZHTMLParserBuilder()
        builder = builder.add(ExtendTagName("zhgchgli"))
        XCTAssertEqual(builder.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element.")
        builder = builder.add(ExtendTagName("zhgchgli"))
        XCTAssertEqual(builder.htmlTags.count, 1, "htmlTags should only have 1 same tag name element.")
        XCTAssertEqual(builder.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element.")
        builder = builder.set(ExtendTagName("zhgchgli"), withCustomStyle: nil)
        XCTAssertEqual(builder.htmlTags.count, 1, "htmlTags should only have 1 same tag name element.")
        XCTAssertEqual(builder.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element.")
    }
    
    func testAddHTMLTagStyleAttribute() {
        var builder = ZHTMLParserBuilder()
        XCTAssertEqual(builder.styleAttributes.count, 0, "styleAttributes should be empty after init.")
        XCTAssertEqual(builder.idAttributes.count, 0, "idAttributes should be empty after init.")
        XCTAssertEqual(builder.classAttributes.count, 0, "classAttributes should be empty after init.")
        
        builder = builder.add(ExtendHTMLTagStyleAttribute(styleName: "zhgchgli", render: { _ in
            return nil
        }))
        XCTAssertEqual(builder.styleAttributes.count, 1, "styleAttributes should have 1 element.")
        XCTAssertEqual(builder.styleAttributes[0].styleName, "zhgchgli", "styleAttributes should have zhgchgli style name element.")
        
        builder = builder.add(HTMLTagClassAttribute(className: "zhgchgli", render: {
            return nil
        }))
        XCTAssertEqual(builder.classAttributes.count, 1, "classAttributes should have 1 element.")
        XCTAssertEqual(builder.classAttributes[0].className, "zhgchgli", "classAttributes should have zhgchgli class element.")
        
        builder = builder.add(HTMLTagIdAttribute(idName: "zhgchgli", render: {
            return nil
        }))
        XCTAssertEqual(builder.idAttributes.count, 1, "idAttributes should have 1 element.")
        XCTAssertEqual(builder.idAttributes[0].idName, "zhgchgli", "idAttributes should have zhgchgli id element.")
    }
    
    func testBuild() {
        let rootMarkupStyle = MarkupStyle(kern: 9999)
        let zhgchgliTagMarkupStyle = MarkupStyle(kern: 8888)
        let zhgchgliStyleMarkupStyle = MarkupStyle(kern: 7777)
        
        let parser = ZHTMLParserBuilder().add(ExtendTagName("zhgchgli"), withCustomStyle: zhgchgliTagMarkupStyle).add(ExtendHTMLTagStyleAttribute(styleName: "zhgchgli", render: { _ in
            return zhgchgliStyleMarkupStyle
        })).set(rootStyle: rootMarkupStyle).build()
        
        XCTAssertEqual(parser.rootStyle?.kern, rootMarkupStyle.kern, "rootStyle should be set in parser result")
        XCTAssertEqual(parser.htmlTags.count, 1, "htmlTags should have 1 element in parser result")
        XCTAssertEqual(parser.styleAttributes.count, 1, "styleAttributes should have 1 element in parser result")
        XCTAssertEqual(parser.htmlTags[0].tagName.string, "zhgchgli", "htmlTags should have zhgchgli tag name element in parser result")
        XCTAssertEqual(parser.htmlTags[0].customStyle?.kern, zhgchgliTagMarkupStyle.kern, "htmlTags should have zhgchgli tag name element with custom style in parser result")
        
        XCTAssertEqual(parser.styleAttributes.count, 1, "styleAttributes should have 1 element in parser result")
        XCTAssertEqual(parser.styleAttributes[0].styleName, "zhgchgli", "styleAttributes should have zhgchgli style element in parser result")
        
        
        XCTAssertEqual((parser.styleAttributes[0] as? ExtendHTMLTagStyleAttribute)?.render("")?.kern, zhgchgliStyleMarkupStyle.kern, "styleAttributes should have zhgchgli style element with custom style in parser result")

    }
}
