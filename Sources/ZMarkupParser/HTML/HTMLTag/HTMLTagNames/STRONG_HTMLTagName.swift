//
//  STRONG_HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/2.
//

import Foundation

public struct STRONG_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.strong.rawValue
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
