//
//  AllMarkupsHasAddToBuilderDefaultListTests.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/21.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class AllMarkupsHasAddToBuilderDefaultListTests: XCTestCase {
    func testCheckDefaultList() {
        let visitor = StubVisitor()
        ZHTMLParserBuilder.htmlTagNames.forEach { tagName in
            let _ = visitor.visit(tagName: tagName)
        }

        XCTAssertEqual(visitor.count, 19, "Must added new pre-defined HTMLTagName to ZHTMLParserBuilder.htmlTagNames")
    }
}

private class StubVisitor: HTMLTagNameVisitor {
    
    typealias Result = Int
    
    private(set) var count: Int = 0
    
    func visit(_ tagName: ExtendTagName) -> Int {
        return count
    }
    
    func visit(_ tagName: A_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: TR_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: TD_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: TH_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: IMG_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
    func visit(_ tagName: TABLE_HTMLTagName) -> Int {
        count += 1
        return count
    }
    
}
