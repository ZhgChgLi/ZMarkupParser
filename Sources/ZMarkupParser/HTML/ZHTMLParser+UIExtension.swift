//
//  ZHTMLParser+UIExtension.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/17.
//

import Foundation
import ZNSTextAttachment

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
    
    func setHtmlString(_ string: String, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        self.setHtmlString(NSAttributedString(string: string), with: parser, completionHandler: completionHandler)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        parser.render(string) { attributedString in
            self.attributedText = attributedString
            self.linkTextAttributes = parser.linkTextAttributes
            completionHandler?(attributedString)
        }
    }
}

public extension UILabel {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        let attributedString = parser.render(string)
        attributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, attributedString.string.utf16.count), options: []) { (value, effectiveRange, nil) in
            guard let attachment = value as? ZNSTextAttachment else {
                return
            }
            
            attachment.register(label: self)
        }
        
        self.attributedText = attributedString
    }
    
    func setHtmlString(_ string: String, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        self.setHtmlString(NSAttributedString(string: string), with: parser, completionHandler: completionHandler)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        parser.render(string) { attributedString in
            attributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, attributedString.string.utf16.count), options: []) { (value, effectiveRange, nil) in
                guard let attachment = value as? ZNSTextAttachment else {
                    return
                }
                
                attachment.register(label: self)
            }
            
            self.attributedText = attributedString
            completionHandler?(attributedString)
        }
    }
}
#elseif canImport(AppKit)
public extension NSTextView {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.textStorage?.setAttributedString(parser.render(string))
        self.linkTextAttributes = parser.linkTextAttributes
    }
    
    func setHtmlString(_ string: String, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        self.setHtmlString(NSAttributedString(string: string), with: parser, completionHandler: completionHandler)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        parser.render(string) { attributedString in
            self.textStorage?.setAttributedString(parser.render(string))
            self.linkTextAttributes = parser.linkTextAttributes
            completionHandler?(attributedString)
        }
    }
}

public extension NSTextField {
    func setHtmlString(_ string: String, with parser: ZHTMLParser) {
        self.setHtmlString(NSAttributedString(string: string), with: parser)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser) {
        self.attributedStringValue = parser.render(string)
    }
    
    func setHtmlString(_ string: String, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        self.setHtmlString(NSAttributedString(string: string), with: parser, completionHandler: completionHandler)
    }
    
    func setHtmlString(_ string: NSAttributedString, with parser: ZHTMLParser, completionHandler: ((NSAttributedString) -> Void)? = nil) {
        parser.render(string) { attributedString in
            self.attributedStringValue = attributedString
            completionHandler?(attributedString)
        }
    }
}
#endif
