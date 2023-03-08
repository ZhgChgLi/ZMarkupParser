//
//  ListMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

final class ListMarkup: Markup {
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    let styleList: MarkupStyleList
    init(styleList: MarkupStyleList) {
        self.styleList = styleList
    }
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
