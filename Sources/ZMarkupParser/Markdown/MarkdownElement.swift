//
//  MarkdownElement.swift
//  
//
//  Created by zhgchgli on 2023/3/27.
//

import Foundation

protocol MarkdownElement: AnyObject {
    
}

class BoldMarkdownElement: MarkdownElement {
    
}

class LinkMarkdownElement: MarkdownElement {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

class ItalicMarkdownElement: MarkdownElement {
    
}
