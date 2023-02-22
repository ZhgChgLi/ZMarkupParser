//
//  ZHTMLParserBuilder.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public final class ZHTMLParserBuilder {
    
    private(set) var htmlTags: [HTMLTag] = []
    private(set) var styleAttributes: [HTMLTagStyleAttribute] = []
    private(set) var rootStyle: MarkupStyle?
    
    public init() {
        
    }
    
    public static func initWithDefault() -> Self {
        var builder = Self.init()
        for htmlTagName in ZHTMLParserBuilder.htmlTagNames {
            builder = builder.add(htmlTagName)
        }
        for styleAttribute in ZHTMLParserBuilder.styleAttributes {
            builder = builder.add(styleAttribute)
        }
        return builder
    }
    
    public func set(_ htmlTagName: HTMLTagName, withCustomStyle markupStyle: MarkupStyle?) -> Self {
        return self.add(htmlTagName, withCustomStyle: markupStyle)
    }
    
    public func add(_ htmlTagName: HTMLTagName, withCustomStyle markupStyle: MarkupStyle? = nil) -> Self {
        htmlTags.removeAll { htmlTag in
            return htmlTag.tagName.string == htmlTagName.string
        }
        
        htmlTags.append(HTMLTag(tagName: htmlTagName, customStyle: markupStyle))
        
        return self
    }
    
    public func add(_ styleAttribute: HTMLTagStyleAttribute) -> Self {
        styleAttributes.removeAll { thisStyleAttribute in
            return thisStyleAttribute.styleName == styleAttribute.styleName
        }
        
        styleAttributes.append(styleAttribute)
        
        return self
    }
    
    public func set(rootStyle: MarkupStyle) -> Self {
        self.rootStyle = rootStyle
        return self
    }
    
    public func build() -> ZHTMLParser {
        return ZHTMLParser(htmlTags: htmlTags, styleAttributes: styleAttributes, rootStyle: rootStyle)
    }
}
