//
//  HTMLElementMarkupComponent.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation

struct HTMLElementMarkupComponent: MarkupComponent {
    struct HTMLElement {
        let tag: HTMLTag
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
    }
    
    typealias T = HTMLElement
    
    let markup: Markup
    let value: HTMLElement
    init(markup: Markup, value: HTMLElement) {
        self.markup = markup
        self.value = value
    }
}
