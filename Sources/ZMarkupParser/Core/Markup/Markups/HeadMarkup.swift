//
//  HeadMarkup.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/13.
//

import Foundation

final class HeadMarkup: Markup {
    enum Level {
        case h1
        case h2
        case h3
        case h4
        case h5
        case h6
    }
    
    let levle: Level
    init(levle: Level) {
        self.levle = levle
    }
    
    weak var parentMarkup: Markup? = nil
    var childMarkups: [Markup] = []
    
    func accept<V>(_ visitor: V) -> V.Result where V : MarkupVisitor {
        return visitor.visit(self)
    }
}
