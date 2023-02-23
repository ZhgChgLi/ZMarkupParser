//
//  RawStringMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

final class RawStringMarkup: Markup {
    let style: MarkupStyle? = nil
    let attributedString: NSAttributedString
    
    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
