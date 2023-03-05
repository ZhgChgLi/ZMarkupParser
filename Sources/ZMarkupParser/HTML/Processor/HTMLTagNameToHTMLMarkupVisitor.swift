//
//  HTMLTagNameToMarkupVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation
import ZNSTextAttachment

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct HTMLTagNameToMarkupVisitor: HTMLTagNameVisitor {
    typealias Result = Markup
    
    let tagAttributedString: NSAttributedString
    let attributes: [String : String]?
    let style: MarkupStyle?
    init(tagAttributedString: NSAttributedString, attributes: [String: String]?, with style: MarkupStyle?) {
        self.tagAttributedString = tagAttributedString
        self.attributes = attributes
        self.style = style
    }
    
    func visit(_ tagName: A_HTMLTagName) -> Result {
        return LinkMarkup(style: style)
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Result {
        return BoldMarkup(style: style)
    }
    
    func visit(_ tagName: ExtendTagName) -> Result {
        return ExtendMarkup(style: style)
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Result {
        return BreakLineMarkup(style: style)
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Result {
        return ParagraphMarkup(style: style)
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Result {
        return HorizontalLineMarkup(dashLength: tagName.dashLength, style: style)
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Result {
        return ItalicMarkup(style: style)
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Result {
        return ListItemMarkup(style: style)
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Result {
        return OrderListMarkup(style: style)
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Result {
        return ParagraphMarkup(style: style)
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Result {
        return InlineMarkup(style: style)
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Result {
        return BoldMarkup(style: style)
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Result {
        return UnderlineMarkup(style: style)
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Result {
        return UnorderListMarkup(style: style)
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Result {
        return DeletelineMarkup(style: style)
    }
    
    func visit(_ tagName: IMG_HTMLTagName) -> Result {
        guard let srcString = attributes?["src"],
              let srcURL = URL(string: srcString) else {
            return ExtendMarkup(style: style)
        }
        
        let width: CGFloat?
        if let widthString = attributes?["width"], let widthFloat = Float(widthString) {
            width = CGFloat(widthFloat)
        } else {
            width = nil
        }
        
        let height: CGFloat?
        if let heightString = attributes?["height"], let heightFloat = Float(heightString) {
            height = CGFloat(heightFloat)
        } else {
            height = nil
        }
        
        let attachment = ZNSTextAttachment(imageURL: srcURL, imageWidth: width, imageHeight: height, placeholderImage: placeholderImage(size: CGSize(width: width ?? 50, height: height ?? 50)))
        
        attachment.delegate = tagName.handler
        attachment.dataSource = tagName.handler
        
        let imageMarkup = ImageMarkup(attachment: attachment, width: width, height: height, style: style)
        return imageMarkup
    }
}

private extension HTMLTagNameToMarkupVisitor {
    
    #if canImport(UIKit)
    func placeholderImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIColor.gray.setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    #elseif canImport(AppKit)
    func placeholderImage(size: CGSize) -> NSImage? {
        let image = NSImage()
        image.backgroundColor = .gray
        image.size = size
        return image
    }
    #endif
}
