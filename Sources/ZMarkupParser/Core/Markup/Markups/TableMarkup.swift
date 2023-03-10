//
//  TableMarkup.swift
//  
//
//  Created by zhgchgli on 2023/3/10.
//

import Foundation

final class TableMarkup: Markup {
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}

