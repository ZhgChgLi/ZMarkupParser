//
//  CodeMarkup.swift
//  
//
//  Created by zhgchgli on 2023/4/11.
//

import Foundation

final class CodeMarkup: Markup {
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
