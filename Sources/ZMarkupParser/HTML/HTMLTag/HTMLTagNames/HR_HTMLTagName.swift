//
//  HR_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/3.
//

import Foundation

public struct HR_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.hr.rawValue
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
