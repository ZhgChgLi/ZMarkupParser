//
//  MarkupStyleParagraphStyle.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/4.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct MarkupStyleParagraphStyle: MarkupStyleItem {
    public var lineSpacing:CGFloat? = nil
    public var paragraphSpacing:CGFloat? = nil
    public var alignment:NSTextAlignment? = nil
    public var headIndent:CGFloat? = nil
    public var tailIndent:CGFloat? = nil
    public var firstLineHeadIndent:CGFloat? = nil
    public var minimumLineHeight:CGFloat? = nil
    public var maximumLineHeight:CGFloat? = nil
    public var lineBreakMode:NSLineBreakMode? = nil
    public var baseWritingDirection:NSWritingDirection? = nil
    public var lineHeightMultiple:CGFloat? = nil
    public var paragraphSpacingBefore:CGFloat? = nil
    public var hyphenationFactor:Float? = nil
    public var usesDefaultHyphenation:Bool? = nil
    public var tabStops: [NSTextTab]? = nil
    public var defaultTabInterval:CGFloat? = nil
    public var textLists: [NSTextList]? = nil
    public var allowsDefaultTighteningForTruncation:Bool? = nil
    public var lineBreakStrategy: NSParagraphStyle.LineBreakStrategy? = nil
    
    public init(lineSpacing: CGFloat? = nil, paragraphSpacing: CGFloat? = nil, alignment: NSTextAlignment? = nil, headIndent: CGFloat? = nil, tailIndent: CGFloat? = nil, firstLineHeadIndent: CGFloat? = nil, minimumLineHeight: CGFloat? = nil, maximumLineHeight: CGFloat? = nil, lineBreakMode: NSLineBreakMode? = nil, baseWritingDirection: NSWritingDirection? = nil, lineHeightMultiple: CGFloat? = nil, paragraphSpacingBefore: CGFloat? = nil, hyphenationFactor: Float? = nil, usesDefaultHyphenation: Bool? = nil, tabStops: [NSTextTab]? = nil, defaultTabInterval: CGFloat? = nil, textLists: [NSTextList]? = nil, allowsDefaultTighteningForTruncation: Bool? = nil, lineBreakStrategy: NSParagraphStyle.LineBreakStrategy? = nil) {
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.alignment = alignment
        self.headIndent = headIndent
        self.tailIndent = tailIndent
        self.firstLineHeadIndent = firstLineHeadIndent
        self.minimumLineHeight = minimumLineHeight
        self.maximumLineHeight = maximumLineHeight
        self.lineBreakMode = lineBreakMode
        self.baseWritingDirection = baseWritingDirection
        self.lineHeightMultiple = lineHeightMultiple
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.hyphenationFactor = hyphenationFactor
        self.usesDefaultHyphenation = usesDefaultHyphenation
        self.tabStops = tabStops
        self.defaultTabInterval = defaultTabInterval
        self.textLists = textLists
        self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        self.lineBreakStrategy = lineBreakStrategy
    }
    
    public init(_ paragraphStyle: NSParagraphStyle) {
        self.lineSpacing = paragraphStyle.lineSpacing
        self.paragraphSpacing = paragraphStyle.paragraphSpacing
        self.alignment = paragraphStyle.alignment
        self.headIndent = paragraphStyle.headIndent
        self.tailIndent = paragraphStyle.tailIndent
        self.firstLineHeadIndent = paragraphStyle.firstLineHeadIndent
        self.minimumLineHeight = paragraphStyle.minimumLineHeight
        self.maximumLineHeight = paragraphStyle.maximumLineHeight
        self.lineBreakMode = paragraphStyle.lineBreakMode
        self.baseWritingDirection = paragraphStyle.baseWritingDirection
        self.lineHeightMultiple = paragraphStyle.lineHeightMultiple
        self.paragraphSpacingBefore = paragraphStyle.paragraphSpacingBefore
        self.hyphenationFactor = paragraphStyle.hyphenationFactor
        #if canImport(UIKit)
        if #available(iOS 15.0, *) {
            self.usesDefaultHyphenation = paragraphStyle.usesDefaultHyphenation
        } else {
            // Fallback on earlier versions
        }
        #elseif canImport(AppKit)
        if #available(macOS 12.0, *) {
            self.usesDefaultHyphenation = paragraphStyle.usesDefaultHyphenation
        } else {
            // Fallback on earlier versions
        }
        #endif
        self.tabStops = paragraphStyle.tabStops
        self.defaultTabInterval = paragraphStyle.defaultTabInterval
        self.textLists = paragraphStyle.textLists
        self.allowsDefaultTighteningForTruncation = paragraphStyle.allowsDefaultTighteningForTruncation
        self.lineBreakStrategy = paragraphStyle.lineBreakStrategy
    }

    mutating func fillIfNil(from: MarkupStyleParagraphStyle?) {
        self.lineSpacing = self.lineSpacing ?? from?.lineSpacing
        self.paragraphSpacing = self.paragraphSpacing ?? from?.paragraphSpacing
        self.alignment = self.alignment ?? from?.alignment
        self.headIndent = self.headIndent ?? from?.headIndent
        self.tailIndent = self.tailIndent ?? from?.tailIndent
        self.firstLineHeadIndent = self.firstLineHeadIndent ?? from?.firstLineHeadIndent
        self.minimumLineHeight = self.minimumLineHeight ?? from?.minimumLineHeight
        self.maximumLineHeight = self.maximumLineHeight ?? from?.maximumLineHeight
        self.lineBreakMode = self.lineBreakMode ?? from?.lineBreakMode
        self.baseWritingDirection = self.baseWritingDirection ?? from?.baseWritingDirection
        self.lineHeightMultiple = self.lineHeightMultiple ?? from?.lineHeightMultiple
        self.paragraphSpacingBefore = self.paragraphSpacingBefore ?? from?.paragraphSpacingBefore
        self.hyphenationFactor = self.hyphenationFactor ?? from?.hyphenationFactor
        self.usesDefaultHyphenation = self.usesDefaultHyphenation ?? from?.usesDefaultHyphenation
        self.defaultTabInterval = self.defaultTabInterval ?? from?.defaultTabInterval
        
        if let from = from?.tabStops {
            var to = self.tabStops ?? []
            to.append(contentsOf: from)
            self.tabStops = to
        }
        
        if let from = from?.textLists {
            var to = self.textLists ?? []
            to.append(contentsOf: from)
            self.textLists = to
        }
        
        self.allowsDefaultTighteningForTruncation = self.allowsDefaultTighteningForTruncation ?? from?.allowsDefaultTighteningForTruncation
        self.lineBreakStrategy = self.lineBreakStrategy ?? from?.lineBreakStrategy
    }
    
    func isNil() -> Bool {
        return !([lineSpacing,
                 paragraphSpacing,
                 alignment,
                 headIndent,
                 tailIndent,
                 firstLineHeadIndent,
                 minimumLineHeight,
                 maximumLineHeight,
                 lineBreakMode,
                 baseWritingDirection,
                 lineHeightMultiple,
                 paragraphSpacingBefore,
                 hyphenationFactor,
                 usesDefaultHyphenation,
                 tabStops,
                 defaultTabInterval,
                 textLists,
                 allowsDefaultTighteningForTruncation,
                 lineBreakStrategy] as [Any?]).contains(where: { $0 != nil})
    }
}

extension MarkupStyleParagraphStyle {
    
    func getParagraphStyle() -> NSParagraphStyle? {
        guard !isNil() else { return nil }
        
        let mutableParagraphStyle = NSMutableParagraphStyle()
        
        if let lineSpacing = self.lineSpacing {
            mutableParagraphStyle.lineSpacing = lineSpacing
        }
        if let paragraphSpacing = self.paragraphSpacing {
            mutableParagraphStyle.paragraphSpacing = paragraphSpacing
        }
        if let alignment = self.alignment {
            mutableParagraphStyle.alignment = alignment
        }
        if let headIndent = self.headIndent {
            mutableParagraphStyle.headIndent = headIndent
        }
        if let tailIndent = self.tailIndent {
            mutableParagraphStyle.tailIndent = tailIndent
        }
        if let firstLineHeadIndent = self.firstLineHeadIndent {
            mutableParagraphStyle.firstLineHeadIndent = firstLineHeadIndent
        }
        if let minimumLineHeight = self.minimumLineHeight {
            mutableParagraphStyle.minimumLineHeight = minimumLineHeight
        }
        if let maximumLineHeight = self.maximumLineHeight {
            mutableParagraphStyle.maximumLineHeight = maximumLineHeight
        }
        if let lineBreakMode = self.lineBreakMode {
            mutableParagraphStyle.lineBreakMode = lineBreakMode
        }
        if let baseWritingDirection = self.baseWritingDirection {
            mutableParagraphStyle.baseWritingDirection = baseWritingDirection
        }
        if let lineHeightMultiple = self.lineHeightMultiple {
            mutableParagraphStyle.lineHeightMultiple = lineHeightMultiple
        }
        if let paragraphSpacingBefore = self.paragraphSpacingBefore {
            mutableParagraphStyle.paragraphSpacingBefore = paragraphSpacingBefore
        }
        if let hyphenationFactor = self.hyphenationFactor {
            mutableParagraphStyle.hyphenationFactor = hyphenationFactor
        }
        
        #if canImport(UIKit)
        if #available(iOS 15.0, *) {
            if let usesDefaultHyphenation = self.usesDefaultHyphenation {
                mutableParagraphStyle.usesDefaultHyphenation = usesDefaultHyphenation
            }
        } else {
            // Fallback on earlier versions
        }
        #elseif canImport(AppKit)
        if #available(macOS 12.0, *) {
            if let usesDefaultHyphenation = self.usesDefaultHyphenation {
                mutableParagraphStyle.usesDefaultHyphenation = usesDefaultHyphenation
            }
        } else {
            // Fallback on earlier versions
        }
        #endif

        
        if let tabStops = self.tabStops {
            mutableParagraphStyle.tabStops = tabStops
        }
        if let defaultTabInterval = self.defaultTabInterval {
            mutableParagraphStyle.defaultTabInterval = defaultTabInterval
        }
        if let textLists = self.textLists {
            mutableParagraphStyle.textLists = textLists
        }
        if let allowsDefaultTighteningForTruncation = self.allowsDefaultTighteningForTruncation {
            mutableParagraphStyle.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        }
        if let lineBreakStrategy = self.lineBreakStrategy {
            mutableParagraphStyle.lineBreakStrategy = lineBreakStrategy
        }
        
        return mutableParagraphStyle
    }
}
