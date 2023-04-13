//
//  BLOCKQUOTE_HTMLTagName.swift
//  
//
//  Created by zhgchgli on 2023/4/11.
//

import Foundation

public struct BLOCKQUOTE_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.blockquote.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}

