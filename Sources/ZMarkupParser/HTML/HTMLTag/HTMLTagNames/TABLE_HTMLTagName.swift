//
//  TABLE_HTMLTagName.swift
//  
//
//  Created by zhgchgli on 2023/3/10.
//

import Foundation

public struct TABLE_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.table.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
