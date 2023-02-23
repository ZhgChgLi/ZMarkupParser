//
//  OrderListMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

final class OrderListMarkup: Markup {
    let style: MarkupStyle?
    
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    init(style: MarkupStyle?) {
        self.style = style
    }
    
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
