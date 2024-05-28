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
    
    func testReduceBreaklineInResultNSAttributedString() {
        //        <div>
        //          <div style="background-color:red">
        //            <ul>
        //              <li>111</li>
        //              <li>22<br/>22</li>
        //              <li>333<br/><br/></li>
        //            </ul>
        //          </div>
        //        </div>
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let rootMarkup = RootMarkup()
        let paragraphMarkup_1 = ParagraphMarkup()
        let paragraphMarkup_2 = ParagraphMarkup()
        let listMarkup = ListMarkup(styleList: MarkupStyleList(type: .circle, startingItemNumber: 1))
        let listItemMarkup_1 = ListItemMarkup()
        listItemMarkup_1.appendChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "11")))
        let listItemMarkup_2 = ListItemMarkup()
        listItemMarkup_2.appendChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "22")))
        listItemMarkup_2.appendChild(markup: BreakLineMarkup())
        listItemMarkup_2.appendChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "22")))
        listItemMarkup_2.appendChild(markup: BreakLineMarkup())
        let listItemMarkup_3 = ListItemMarkup()
        listItemMarkup_3.appendChild(markup: RawStringMarkup(attributedString: NSAttributedString(string: "333")))
        listItemMarkup_3.appendChild(markup: BreakLineMarkup())
        listItemMarkup_3.appendChild(markup: BreakLineMarkup())
        listMarkup.appendChild(markup: listItemMarkup_1)
        listMarkup.appendChild(markup: listItemMarkup_2)
        listMarkup.appendChild(markup: listItemMarkup_3)
        
        paragraphMarkup_1.appendChild(markup: listMarkup)
        paragraphMarkup_2.appendChild(markup: paragraphMarkup_1)
        rootMarkup.appendChild(markup: paragraphMarkup_2)
        
        let result = visitor.visit(rootMarkup).string
        
        XCTAssertEqual(result, "\t◦\t11\n\t◦\t22\n22\n\t◦\t333\n\n", "Breakline reduce failed!")
    }
    
    
    func testApplyMarkupStyle() {
        let visitor = MarkupNSAttributedStringVisitor(components: [], rootStyle: nil)
        let result = visitor.applyMarkupStyle(NSAttributedString(string: "Test"), with: MarkupStyle(kern: 999))
        
        XCTAssertEqual(result.attributes(at: 0, effectiveRange: nil)[.kern] as? Int, 999)
    }
}
