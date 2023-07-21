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
    
    let attributes: [String: String]?
    let isSelfClosingTag: Bool

    init(attributes: [String : String]?, isSelfClosingTag: Bool) {
        self.attributes = attributes
        self.isSelfClosingTag = isSelfClosingTag
    }
    
    func visit(_ tagName: A_HTMLTagName) -> Result {
        return LinkMarkup()
    }
    
    func visit(_ tagName: B_HTMLTagName) -> Result {
        print("asdasd", attributes)
        return BoldMarkup()
    }
    
    func visit(_ tagName: ExtendTagName) -> Result {
        return ExtendMarkup()
    }
    
    func visit(_ tagName: BR_HTMLTagName) -> Result {
        return BreakLineMarkup()
    }
    
    func visit(_ tagName: DIV_HTMLTagName) -> Result {
        if isSelfClosingTag {
            return BreakLineMarkup()
        } else {
            return ParagraphMarkup()
        }
    }
    
    func visit(_ tagName: HR_HTMLTagName) -> Result {
        return HorizontalLineMarkup(dashLength: tagName.dashLength)
    }
    
    func visit(_ tagName: I_HTMLTagName) -> Result {
        return ItalicMarkup()
    }
    
    func visit(_ tagName: LI_HTMLTagName) -> Result {
        return ListItemMarkup()
    }
    
    func visit(_ tagName: OL_HTMLTagName) -> Result {
        return ListMarkup(styleList: tagName.listStyle)
    }
    
    func visit(_ tagName: P_HTMLTagName) -> Result {
        if isSelfClosingTag {
            return BreakLineMarkup()
        } else {
            return ParagraphMarkup()
        }
    }
    
    func visit(_ tagName: FONT_HTMLTagName) -> Result {
        if let color = attributes?["color"], let markupStyleColor = MarkupStyleColor(string: color) {
            return ColorMarkup(color: markupStyleColor)
        } else {
            return InlineMarkup()
        }
    }
    
    func visit(_ tagName: SPAN_HTMLTagName) -> Result {
        return InlineMarkup()
    }
    
    func visit(_ tagName: STRONG_HTMLTagName) -> Result {
        return BoldMarkup()
    }
    
    func visit(_ tagName: U_HTMLTagName) -> Result {
        return UnderlineMarkup()
    }
    
    func visit(_ tagName: UL_HTMLTagName) -> Result {
        return ListMarkup(styleList: tagName.listStyle)
    }
    
    func visit(_ tagName: DEL_HTMLTagName) -> Result {
        return DeletelineMarkup()
    }
    
    func visit(_ tagName: TR_HTMLTagName) -> Result {
        return TableRowMarkup()
    }
    
    func visit(_ tagName: TD_HTMLTagName) -> Result {
        return TableColumnMarkup(isHeader: false, fixedMaxLength: tagName.fixedMaxLength, spacing: tagName.spacing)
    }
    
    func visit(_ tagName: TH_HTMLTagName) -> Result {
        return TableColumnMarkup(isHeader: true, fixedMaxLength: tagName.fixedMaxLength, spacing: tagName.spacing)
    }
    
    func visit(_ tagName: TABLE_HTMLTagName) -> Result {
        return TableMarkup()
    }
    
    func visit(_ tagName: H1_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h1)
    }
    
    func visit(_ tagName: H2_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h2)
    }
    
    func visit(_ tagName: H3_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h3)
    }
    
    func visit(_ tagName: H4_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h4)
    }
    
    func visit(_ tagName: H5_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h5)
    }
    
    func visit(_ tagName: H6_HTMLTagName) -> Result {
        return HeadMarkup(levle: .h6)
    }
    
    func visit(_ tagName: S_HTMLTagName) -> Result {
        return DeletelineMarkup()
    }
    
    func visit(_ tagName: PRE_HTMLTagName) -> Result {
        return BlockQuoteMarkup()
    }
    
    func visit(_ tagName: BLOCKQUOTE_HTMLTagName) -> Result {
        return BlockQuoteMarkup()
    }
    
    func visit(_ tagName: CODE_HTMLTagName) -> Result {
        return CodeMarkup()
    }
    
    func visit(_ tagName: EM_HTMLTagName) -> Result {
        return ItalicMarkup()
    }
    
    func visit(_ tagName: IMG_HTMLTagName) -> Result {
        guard let srcString = attributes?["src"],
              let srcURL = URL(string: srcString) else {
            return ExtendMarkup()
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
        
        let imageMarkup = ImageMarkup(attachment: attachment, width: width, height: height)
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
