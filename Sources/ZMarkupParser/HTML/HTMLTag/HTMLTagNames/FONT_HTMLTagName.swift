//
//  FONT_HTMLTagName.swift
//  
//
//  Created by zhgchgli on 2023/7/11.
//

import Foundation

public struct FONT_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.font.rawValue
    
    public init() {
        
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
