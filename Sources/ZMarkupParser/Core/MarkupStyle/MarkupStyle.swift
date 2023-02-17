//
//  MarkupStyle.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/9.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
public struct MarkupStyle {
    public var font:MarkupStyleFont
    public var paragraphStyle:MarkupStyleParagraphStyle
    public var foregroundColor:MarkupStyleColor? = nil
    public var backgroundColor:MarkupStyleColor? = nil
    public var ligature:NSNumber? = nil
    public var kern:NSNumber? = nil
    public var tracking:NSNumber? = nil
    public var strikethroughStyle:NSUnderlineStyle? = nil
    public var underlineStyle:NSUnderlineStyle? = nil
    public var strokeColor:MarkupStyleColor? = nil
    public var strokeWidth:NSNumber? = nil
    public var shadow:NSShadow? = nil
    public var textEffect:String? = nil
    public var attachment:NSTextAttachment? = nil
    public var link:URL? = nil
    public var baselineOffset:NSNumber? = nil
    public var underlineColor:MarkupStyleColor? = nil
    public var strikethroughColor:MarkupStyleColor? = nil
    public var obliqueness:NSNumber? = nil
    public var expansion:NSNumber? = nil
    public var writingDirection:NSNumber? = nil
    public var verticalGlyphForm:NSNumber? = nil
    
    public init(font: MarkupStyleFont = MarkupStyleFont(), paragraphStyle: MarkupStyleParagraphStyle = MarkupStyleParagraphStyle(), foregroundColor: MarkupStyleColor? = nil, backgroundColor: MarkupStyleColor? = nil, ligature: NSNumber? = nil, kern: NSNumber? = nil, tracking: NSNumber? = nil, strikethroughStyle: NSUnderlineStyle? = nil, underlineStyle: NSUnderlineStyle? = nil, strokeColor: MarkupStyleColor? = nil, strokeWidth: NSNumber? = nil, shadow: NSShadow? = nil, textEffect: String? = nil, attachment: NSTextAttachment? = nil, link: URL? = nil, baselineOffset: NSNumber? = nil, underlineColor: MarkupStyleColor? = nil, strikethroughColor: MarkupStyleColor? = nil, obliqueness: NSNumber? = nil, expansion: NSNumber? = nil, writingDirection: NSNumber? = nil, verticalGlyphForm: NSNumber? = nil) {
        self.font = font
        self.paragraphStyle = paragraphStyle
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.ligature = ligature
        self.kern = kern
        self.tracking = tracking
        self.strikethroughStyle = strikethroughStyle
        self.underlineStyle = underlineStyle
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.shadow = shadow
        self.textEffect = textEffect
        self.attachment = attachment
        self.link = link
        self.baselineOffset = baselineOffset
        self.underlineColor = underlineColor
        self.strikethroughColor = strikethroughColor
        self.obliqueness = obliqueness
        self.expansion = expansion
        self.writingDirection = writingDirection
        self.verticalGlyphForm = verticalGlyphForm
    }
    
    mutating func fillIfNil(from: MarkupStyle?) {
        guard let from = from else { return }
        
        var currentFont = self.font
        currentFont.fillIfNil(from: from.font)
        self.font = currentFont
        
        var currentParagraphStyle = self.paragraphStyle
        currentParagraphStyle.fillIfNil(from: from.paragraphStyle)
        self.paragraphStyle = currentParagraphStyle
        
        self.foregroundColor = self.foregroundColor ?? from.foregroundColor
        self.backgroundColor = self.backgroundColor ?? from.backgroundColor
        self.ligature = self.ligature ?? from.ligature
        self.kern = self.kern ?? from.kern
        self.tracking = self.tracking ?? from.tracking
        self.strikethroughStyle = self.strikethroughStyle ?? from.strikethroughStyle
        self.underlineStyle = self.underlineStyle ?? from.underlineStyle
        self.strokeColor = self.strokeColor ?? from.strokeColor
        self.strokeWidth = self.strokeWidth ?? from.strokeWidth
        self.shadow = self.shadow ?? from.shadow
        self.textEffect = self.textEffect ?? from.textEffect
        self.attachment = self.attachment ?? from.attachment
        self.link = self.link ?? from.link
        self.baselineOffset = self.baselineOffset ?? from.baselineOffset
        self.underlineColor = self.underlineColor ?? from.underlineColor
        self.strikethroughColor = self.strikethroughColor ?? from.strikethroughColor
        self.obliqueness = self.obliqueness ?? from.obliqueness
        self.expansion = self.expansion ?? from.expansion
        self.writingDirection = self.writingDirection ?? from.writingDirection
        self.verticalGlyphForm = self.verticalGlyphForm ?? from.verticalGlyphForm
    }
    
    func render() -> [NSAttributedString.Key: Any] {
        var data: [NSAttributedString.Key: Any] = [:]
        
        data[.font] = font.getFont()
        data[.paragraphStyle] = paragraphStyle.getParagraphStyle()
        
        if let foregroundColor = self.foregroundColor {
            data[.foregroundColor] = foregroundColor.getColor()
        }
        if let backgroundColor = self.backgroundColor {
            data[.backgroundColor] = backgroundColor.getColor()
        }
        if let ligature = self.ligature {
            data[.ligature] = ligature
        }
        if let kern = self.kern {
            data[.kern] = kern
        }
        if let tracking = self.tracking {
            if #available(iOS 14.0, *) {
                data[.tracking] = tracking
            }
        }
        if let strikethroughStyle = self.strikethroughStyle {
            data[.strikethroughStyle] = strikethroughStyle.rawValue
        }
        if let underlineStyle = self.underlineStyle {
            data[.underlineStyle] = underlineStyle.rawValue
        }
        if let strokeColor = self.strokeColor {
            data[.strokeColor] = strokeColor.getColor()
        }
        if let strokeWidth = self.strokeWidth {
            data[.strokeWidth] = strokeWidth
        }
        if let shadow = self.shadow {
            data[.shadow] = shadow
        }
        if let textEffect = self.textEffect {
            data[.textEffect] = textEffect
        }
        if let attachment = self.attachment {
            data[.attachment] = attachment
        }
        if let link = self.link {
            data[.link] = link
        }
        if let baselineOffset = self.baselineOffset {
            data[.baselineOffset] = baselineOffset
        }
        if let underlineColor = self.underlineColor {
            data[.underlineColor] = underlineColor.getColor()
        }
        if let strikethroughColor = self.strikethroughColor {
            data[.strikethroughColor] = strikethroughColor.getColor()
        }
        if let obliqueness = self.obliqueness {
            data[.obliqueness] = obliqueness
        }
        if let expansion = self.expansion {
            data[.expansion] = expansion
        }
        if let writingDirection = self.writingDirection {
            data[.writingDirection] = writingDirection
        }
        if let verticalGlyphForm = self.verticalGlyphForm {
            data[.verticalGlyphForm] = verticalGlyphForm
        }
        return data
    }
}

#elseif canImport(AppKit)
public struct MarkupStyle {
    public var nativeFont:NSFont? = nil
    public var font:MarkupStyleFont
    public var paragraphStyle:MarkupStyleParagraphStyle
    public var foregroundColor:MarkupStyleColor? = nil
    public var backgroundColor:MarkupStyleColor? = nil
    public var ligature:NSNumber? = nil
    public var kern:NSNumber? = nil
    public var tracking:NSNumber? = nil
    public var strikethroughStyle:NSUnderlineStyle? = nil
    public var underlineStyle:NSUnderlineStyle? = nil
    public var strokeColor:MarkupStyleColor? = nil
    public var strokeWidth:NSNumber? = nil
    public var shadow:NSShadow? = nil
    public var textEffect:NSAttributedString.TextEffectStyle? = nil
    public var attachment:NSTextAttachment? = nil
    public var link:URL? = nil
    public var baselineOffset:NSNumber? = nil
    public var underlineColor:MarkupStyleColor? = nil
    public var strikethroughColor:MarkupStyleColor? = nil
    public var obliqueness:NSNumber? = nil
    public var expansion:NSNumber? = nil
    public var writingDirection:NSArray? = nil
    public var verticalGlyphForm:NSNumber? = nil
    public var cursor:NSCursor? = nil
    public var toolTip:String? = nil
    public var markedClauseSegment:NSNumber? = nil
    public var textAlternatives:NSTextAlternatives? = nil
    public var spellingState:NSAttributedString.SpellingState? = nil
    public var superscript:NSNumber? = nil
    public var glyphInfo:NSGlyphInfo? = nil
    
    public init(font: MarkupStyleFont = MarkupStyleFont(), paragraphStyle: MarkupStyleParagraphStyle = MarkupStyleParagraphStyle(), foregroundColor: MarkupStyleColor? = nil, backgroundColor: MarkupStyleColor? = nil, ligature: NSNumber? = nil, kern: NSNumber? = nil, tracking: NSNumber? = nil, strikethroughStyle: NSUnderlineStyle? = nil, underlineStyle: NSUnderlineStyle? = nil, strokeColor: MarkupStyleColor? = nil, strokeWidth: NSNumber? = nil, shadow: NSShadow? = nil, textEffect: NSAttributedString.TextEffectStyle? = nil, attachment: NSTextAttachment? = nil, link: URL? = nil, baselineOffset: NSNumber? = nil, underlineColor: MarkupStyleColor? = nil, strikethroughColor: MarkupStyleColor? = nil, obliqueness: NSNumber? = nil, expansion: NSNumber? = nil, writingDirection: NSArray? = nil, verticalGlyphForm: NSNumber? = nil, cursor: NSCursor? = nil, toolTip: String? = nil, markedClauseSegment: NSNumber? = nil, textAlternatives: NSTextAlternatives? = nil, spellingState: NSAttributedString.SpellingState? = nil, superscript: NSNumber? = nil, glyphInfo: NSGlyphInfo? = nil) {
        self.font = font
        self.paragraphStyle = paragraphStyle
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.ligature = ligature
        self.kern = kern
        self.tracking = tracking
        self.strikethroughStyle = strikethroughStyle
        self.underlineStyle = underlineStyle
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.shadow = shadow
        self.textEffect = textEffect
        self.attachment = attachment
        self.link = link
        self.baselineOffset = baselineOffset
        self.underlineColor = underlineColor
        self.strikethroughColor = strikethroughColor
        self.obliqueness = obliqueness
        self.expansion = expansion
        self.writingDirection = writingDirection
        self.verticalGlyphForm = verticalGlyphForm
        self.cursor = cursor
        self.toolTip = toolTip
        self.markedClauseSegment = markedClauseSegment
        self.textAlternatives = textAlternatives
        self.spellingState = spellingState
        self.superscript = superscript
        self.glyphInfo = glyphInfo
    }
    
    mutating func fillIfNil(from: MarkupStyle?) {
        guard let from = from else { return }
        
        var currentFont = self.font
        currentFont.fillIfNil(from: from.font)
        self.font = currentFont
        
        var currentParagraphStyle = self.paragraphStyle
        currentParagraphStyle.fillIfNil(from: from.paragraphStyle)
        self.paragraphStyle = currentParagraphStyle
        
        self.nativeFont = self.nativeFont ?? from.nativeFont
        self.foregroundColor = self.foregroundColor ?? from.foregroundColor
        self.backgroundColor = self.backgroundColor ?? from.backgroundColor
        self.ligature = self.ligature ?? from.ligature
        self.kern = self.kern ?? from.kern
        self.tracking = self.tracking ?? from.tracking
        self.strikethroughStyle = self.strikethroughStyle ?? from.strikethroughStyle
        self.underlineStyle = self.underlineStyle ?? from.underlineStyle
        self.strokeColor = self.strokeColor ?? from.strokeColor
        self.strokeWidth = self.strokeWidth ?? from.strokeWidth
        self.shadow = self.shadow ?? from.shadow
        self.textEffect = self.textEffect ?? from.textEffect
        self.attachment = self.attachment ?? from.attachment
        self.link = self.link ?? from.link
        self.baselineOffset = self.baselineOffset ?? from.baselineOffset
        self.underlineColor = self.underlineColor ?? from.underlineColor
        self.strikethroughColor = self.strikethroughColor ?? from.strikethroughColor
        self.obliqueness = self.obliqueness ?? from.obliqueness
        self.expansion = self.expansion ?? from.expansion
        self.writingDirection = self.writingDirection ?? from.writingDirection
        self.verticalGlyphForm = self.verticalGlyphForm ?? from.verticalGlyphForm
        self.cursor = self.cursor ?? from.cursor
        self.toolTip = self.toolTip ?? from.toolTip
        self.markedClauseSegment = self.markedClauseSegment ?? from.markedClauseSegment
        self.textAlternatives = self.textAlternatives ?? from.textAlternatives
        self.spellingState = self.spellingState ?? from.spellingState
        self.superscript = self.superscript ?? from.superscript
        self.glyphInfo = self.glyphInfo ?? from.glyphInfo
    }
    
    func render() -> [NSAttributedString.Key: Any] {
        var data: [NSAttributedString.Key: Any] = [:]
        
        data[.font] = font.getFont()
        data[.paragraphStyle] = paragraphStyle.getParagraphStyle()
        
        if let foregroundColor = self.foregroundColor {
            data[.foregroundColor] = foregroundColor.getColor()
        }
        if let backgroundColor = self.backgroundColor {
            data[.backgroundColor] = backgroundColor.getColor()
        }
        if let ligature = self.ligature {
            data[.ligature] = ligature
        }
        if let kern = self.kern {
            data[.kern] = kern
        }
        if let tracking = self.tracking {
            if #available(macOS 11.0, *) {
                data[.tracking] = tracking
            }
        }
        if let strikethroughStyle = self.strikethroughStyle {
            data[.strikethroughStyle] = strikethroughStyle.rawValue
        }
        if let underlineStyle = self.underlineStyle {
            data[.underlineStyle] = underlineStyle.rawValue
        }
        if let strokeColor = self.strokeColor {
            data[.strokeColor] = strokeColor.getColor()
        }
        if let strokeWidth = self.strokeWidth {
            data[.strokeWidth] = strokeWidth
        }
        if let shadow = self.shadow {
            data[.shadow] = shadow
        }
        if let textEffect = self.textEffect {
            data[.textEffect] = textEffect
        }
        if let attachment = self.attachment {
            data[.attachment] = attachment
        }
        if let link = self.link {
            data[.link] = link
        }
        if let baselineOffset = self.baselineOffset {
            data[.baselineOffset] = baselineOffset
        }
        if let underlineColor = self.underlineColor {
            data[.underlineColor] = underlineColor.getColor()
        }
        if let strikethroughColor = self.strikethroughColor {
            data[.strikethroughColor] = strikethroughColor.getColor()
        }
        if let obliqueness = self.obliqueness {
            data[.obliqueness] = obliqueness
        }
        if let expansion = self.expansion {
            data[.expansion] = expansion
        }
        if let writingDirection = self.writingDirection {
            data[.writingDirection] = writingDirection
        }
        if let verticalGlyphForm = self.verticalGlyphForm {
            data[.verticalGlyphForm] = verticalGlyphForm
        }
        if let cursor = self.cursor {
            data[.cursor] = cursor
        }
        if let toolTip = self.toolTip {
            data[.toolTip] = toolTip
        }
        if let markedClauseSegment = self.markedClauseSegment {
            data[.markedClauseSegment] = markedClauseSegment
        }
        if let textAlternatives = self.textAlternatives {
            data[.textAlternatives] = textAlternatives
        }
        if let spellingState = self.spellingState {
            data[.spellingState] = spellingState
        }
        if let superscript = self.superscript {
            data[.superscript] = superscript
        }
        if let glyphInfo = self.glyphInfo {
            data[.glyphInfo] = glyphInfo
        }
        
        return data
    }
}
#endif
