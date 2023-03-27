//
//  MarkdownParsedResultTests.swift
//  
//
//  Created by zhgchgli on 2023/3/27.
//

import Foundation
@testable import ZMarkupParser
import XCTest

final class MarkdownParsedResultTests: XCTestCase {

    func testRangesOf() {
        let data: [MarkdownParsedResult] = [
            .rawString(NSAttributedString(string: "te")),
            .symbol(.asterisk, 4, NSAttributedString(string: "****")),
            .rawString(NSAttributedString(string: "bbii")),
            .symbol(.exclamation, 1, NSAttributedString(string: "!")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***")),
            .rawString(NSAttributedString(string: "te")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***")),
            .rawString(NSAttributedString(string: "te")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***")),
            .symbol(.asterisk, 3, NSAttributedString(string: "***"))
        ]
        
        let result = data.ranges(of: [.match(.asterisk), .any, .match(.asterisk)])
        print(result)
    }
    
}
