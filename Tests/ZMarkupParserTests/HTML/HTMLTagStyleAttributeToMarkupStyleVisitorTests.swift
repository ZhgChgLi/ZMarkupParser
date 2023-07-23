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
}
