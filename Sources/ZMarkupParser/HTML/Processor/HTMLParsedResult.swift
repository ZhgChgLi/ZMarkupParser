//
//  HTMLParsedResult.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

enum HTMLParsedResult {
    case start(StartItem)
    case close(CloseItem)
    case selfClosing(SelfClosingItem)
    case rawString(NSAttributedString)
}

extension HTMLParsedResult {
    class SelfClosingItem {
        let tagName: String
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
        
        init(tagName: String, tagAttributedString: NSAttributedString, attributes: [String : String]?) {
            self.tagName = tagName
            self.tagAttributedString = tagAttributedString
            self.attributes = attributes
        }
    }
    
    class StartItem {
        let tagName: String
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
        var isIsolated: Bool = false
        
        init(tagName: String, tagAttributedString: NSAttributedString, attributes: [String : String]?) {
            self.tagName = tagName
            self.tagAttributedString = tagAttributedString
            self.attributes = attributes
        }
        
        func convertToCloseParsedItem() -> CloseItem {
            return CloseItem(tagName: self.tagName)
        }
        
        func convertToSelfClosingParsedItem() -> SelfClosingItem {
            return SelfClosingItem(tagName: self.tagName, tagAttributedString: self.tagAttributedString, attributes: self.attributes)
        }
    }
    
    class CloseItem {
        let tagName: String
        init(tagName: String) {
            self.tagName = tagName
        }
    }
}
