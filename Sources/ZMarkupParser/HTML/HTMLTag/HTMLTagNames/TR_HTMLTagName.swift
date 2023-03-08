//
//  TR_HTMLTagName.swift
//  
//
//  Created by Harry Li on 2023/3/9.
//

import Foundation

public struct TR_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.tr.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
