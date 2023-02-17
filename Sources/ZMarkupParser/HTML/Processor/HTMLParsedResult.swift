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
    
    case placeholderStart(StartItem)
    case placeholderClose(CloseItem)
    case isolatedStart(StartItem)
    case isolatedClose(CloseItem)
}

extension HTMLParsedResult {
    struct SelfClosingItem {
        let tagName: HTMLTagName
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
    }
    
    struct StartItem {
        let tagName: HTMLTagName
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
        let token: String
        
        func convertToCloseParsedItem() -> CloseItem {
            return CloseItem(tagName: self.tagName, token: self.token)
        }
    }
    
    struct CloseItem {
        let tagName: HTMLTagName
        let token: String
    }
}
