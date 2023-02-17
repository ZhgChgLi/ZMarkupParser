//
//  LI_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct LI_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.li.rawValue
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
