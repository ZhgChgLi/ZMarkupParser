//
//  NSTextCheckingResult+Extension.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

extension NSTextCheckingResult {
    func attributedString(_ attributedString: NSAttributedString, at index: Int) -> NSAttributedString? {
        guard index < self.numberOfRanges else {
            return nil
        }
        
        let range = self.range(at: index)
        
        guard range.location != NSNotFound else {
            return nil
        }
        
        return attributedString.attributedSubstring(from: range)
    }
    
    func attributedString(_ attributedString: NSAttributedString, with name: String) -> NSAttributedString? {
        let range = self.range(withName: name)
        
        guard range.location != NSNotFound else {
            return nil
        }
        
        return attributedString.attributedSubstring(from: range)
    }
    
    func attributedString(_ attributedString: NSAttributedString, with range: NSRange?) -> NSAttributedString? {
        guard let range = range else { return nil }
        guard range.location != NSNotFound else {
            return nil
        }
        
        return attributedString.attributedSubstring(from: range)
    }
}
