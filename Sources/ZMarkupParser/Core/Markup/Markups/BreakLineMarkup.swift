//
//  BreakLineMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

final class BreakLineMarkup: Markup {
    var style: MarkupStyle?
    let reduceable: Bool
    
    init(reduceable: Bool = true, style: MarkupStyle? = nil) {
        self.reduceable = reduceable
        self.style = style
    }
    
    var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
