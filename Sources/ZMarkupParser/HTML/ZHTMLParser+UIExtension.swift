//
//  ZHTMLParser+UIExtension.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/17.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
public extension UITextView {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.attributedText = parser.render(string)
        self.linkTextAttributes = parser.linkTextAttributes
    }
}

public extension UILabel {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.attributedText = parser.render(string)
    }
}
#elseif canImport(AppKit)
import AppKit

public extension NSTextView {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.textStorage?.setAttributedString(parser.render(string))
        self.linkTextAttributes = parser.linkTextAttributes
    }
}

public extension NSTextField {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.attributedStringValue = parser.render(string)
    }
}
#endif
