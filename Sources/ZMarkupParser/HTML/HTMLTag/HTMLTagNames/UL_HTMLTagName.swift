//
//  UL_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct UL_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.ul.rawValue
    public let listStyle: MarkupStyleList
    public init(listStyle: MarkupStyleList = MarkupStyleList(type: .disc, startingItemNumber: 1)) {
        self.listStyle = listStyle
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
