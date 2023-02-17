//
//  DEL_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/15.
//

import Foundation

public struct DEL_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.del.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
