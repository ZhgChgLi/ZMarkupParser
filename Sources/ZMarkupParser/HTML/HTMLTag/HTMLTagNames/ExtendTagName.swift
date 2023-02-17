//
//  ExtendTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public struct ExtendTagName: HTMLTagName {
    public let string: String
    
    public init(_ w3cHTMLTagName: WC3HTMLTagName) {
        self.string = w3cHTMLTagName.rawValue
    }
    
    public init(_ string: String) {
        self.string = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
