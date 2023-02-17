//
//  A_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/1.
//

import Foundation

public struct A_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.a.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
