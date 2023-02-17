//
//  HTMLTagStyleAttribute.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/1.
//

import Foundation

public protocol HTMLTagStyleAttribute {
    var styleName: String { get }
    
    func accept<V: HTMLTagStyleAttributeVisitor>(_ visitor: V) -> V.Result
    func isEqualTo(styleName: String) -> Bool
}

public extension HTMLTagStyleAttribute {
    func isEqualTo(styleName: String) -> Bool {
        return self.styleName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == styleName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
