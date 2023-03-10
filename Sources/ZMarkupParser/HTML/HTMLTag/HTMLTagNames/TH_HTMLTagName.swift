//
//  TH_HTMLTagName.swift
//  
//
//  Created by Harry Li on 2023/3/9.
//

import Foundation

public struct TH_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.th.rawValue
    public let fixedMaxLength: Int?
    public let spacing: Int
    
    public init(fixedMaxLength: Int? = nil, spacing: Int = 3) {
        self.fixedMaxLength = fixedMaxLength
        self.spacing = spacing
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
