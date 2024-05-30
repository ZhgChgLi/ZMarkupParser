//
//  OL_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct OL_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.ol.rawValue
    public let startingItemNumber: Int
    public init(startingItemNumber: Int = 1) {
        self.startingItemNumber = startingItemNumber
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
