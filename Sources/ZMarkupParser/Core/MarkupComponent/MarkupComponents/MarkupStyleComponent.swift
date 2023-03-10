//
//  MarkupStyleComponent.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation

struct MarkupStyleComponent: MarkupComponent {
    typealias T = MarkupStyle
    
    let markup: Markup
    let value: MarkupStyle
    init(markup: Markup, value: MarkupStyle) {
        self.markup = markup
        self.value = value
    }
}
