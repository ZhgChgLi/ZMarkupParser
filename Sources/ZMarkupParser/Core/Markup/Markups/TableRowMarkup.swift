//
//  TableRowMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/9.
//

import Foundation

final class TableRowMarkup: Markup {
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
