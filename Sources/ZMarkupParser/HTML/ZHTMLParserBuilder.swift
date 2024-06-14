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
    private(set) var classAttributes: [HTMLTagClassAttribute] = []
    private(set) var idAttributes: [HTMLTagIdAttribute] = []
    private(set) var rootStyle: MarkupStyle? = .default
    private(set) var policy: MarkupStylePolicy = .respectMarkupStyleFromHTMLStyleAttribute
    
    public init() {
        
    }
    
    public static func initWithDefault() -> Self {
        var builder = Self.init()
        for (htmlTagName, customStyle) in ZHTMLParserBuilder.htmlTagNames {
            builder = builder.add(htmlTagName, withCustomStyle: customStyle)
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
    
    public func add(_ classAttribute: HTMLTagClassAttribute) -> Self {
        classAttributes.removeAll { thisAttribute in
            return thisAttribute.className == classAttribute.className
        }
        
        classAttributes.append(classAttribute)
        
        return self
    }
    
    public func add(_ idAttribute: HTMLTagIdAttribute) -> Self {
        idAttributes.removeAll { thisAttribute in
            return thisAttribute.idName == idAttribute.idName
        }
        
        idAttributes.append(idAttribute)
        
        return self
    }
    
    public func set(rootStyle: MarkupStyle) -> Self {
        self.rootStyle = rootStyle
        return self
    }
    
    public func set(policy: MarkupStylePolicy) -> Self {
        self.policy = policy
        return self
    }
    
    public func build() -> ZHTMLParser {
        return ZHTMLParser(
            htmlTags: htmlTags,
            styleAttributes: styleAttributes,
            classAttributes: classAttributes,
            idAttributes: idAttributes,
            policy: policy,
            rootStyle: rootStyle
        )
    }
}
