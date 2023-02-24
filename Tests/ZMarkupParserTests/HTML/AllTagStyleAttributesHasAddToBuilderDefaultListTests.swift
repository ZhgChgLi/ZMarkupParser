//
//  AllTagStyleAttributesHasAddToBuilderDefaultListTests.swift
//
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class AllTagStyleAttributesHasAddToBuilderDefaultListTests: XCTestCase {
    func testCheckDefaultList() {
        let visitor = StubVisitor()
        ZHTMLParserBuilder.styleAttributes.forEach { style in
            let _ = visitor.visit(styleAttribute: style)
        }
        XCTAssertEqual(visitor.count, 6, "Must added new pre-defined HTMLTagStyleAttribute to ZHTMLParserBuilder.styleAttributes")
    }
}

private class StubVisitor: HTMLTagStyleAttributeVisitor {
    
    typealias Result = Int
    
    private(set) var count: Int = 0
    
    func visit(_ styleAttribute: ExtendHTMLTagStyleAttribute) -> Int {
        return count
    }
    
    func visit(_ styleAttribute: ColorHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
    
    func visit(_ styleAttribute: BackgroundColorHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
    
    func visit(_ styleAttribute: FontSizeHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
    
    func visit(_ styleAttribute: FontWeightHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
    
    func visit(_ styleAttribute: LineHeightHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
    
    func visit(_ styleAttribute: WordSpacingHTMLTagStyleAttribute) -> Int {
        count += 1
        return count
    }
}
