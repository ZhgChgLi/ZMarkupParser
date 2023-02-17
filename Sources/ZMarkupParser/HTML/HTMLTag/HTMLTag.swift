//
//  HTMLTag.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

struct HTMLTag {
    let tagName: HTMLTagName
    let customStyle: MarkupStyle?
    
    init(tagName: HTMLTagName, customStyle: MarkupStyle? = nil) {
        self.tagName = tagName
        self.customStyle = customStyle
    }
}
