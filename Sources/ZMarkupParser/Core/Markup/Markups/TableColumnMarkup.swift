//
//  File.swift
//  
//
//  Created by Harry Li on 2023/3/9.
//

import Foundation

final class TableColumnMarkup: Markup {
    
    let fixedMaxLength: Int?
    let isHeader: Bool
    init(isHeader: Bool, fixedMaxLength: Int?) {
        self.isHeader = isHeader
        self.fixedMaxLength = fixedMaxLength
    }
    
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
