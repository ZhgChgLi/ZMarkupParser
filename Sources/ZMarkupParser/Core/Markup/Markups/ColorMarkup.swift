//
//  ColorMarkup.swift
//  
//
//  Created by zhgchgli on 2023/7/11.
//

import Foundation

final class ColorMarkup: Markup {
    
    let color: MarkupStyleColor
    
    init(color: MarkupStyleColor) {
        self.color = color
    }
        
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
