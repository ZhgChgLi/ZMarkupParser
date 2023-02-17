//
//  HorizontalLineMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/3.
//

import Foundation

final class HorizontalLineMarkup: Markup {
    let style: MarkupStyle?
    let dashLength: Int
    
    var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    init(dashLength: Int, style: MarkupStyle?) {
        self.dashLength = dashLength
        self.style = style
    }
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
