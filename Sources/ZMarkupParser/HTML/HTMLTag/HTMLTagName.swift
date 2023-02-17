//
//  HTMLTagName.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/10.
//

import Foundation

public protocol HTMLTagName {
    var string: String { get }
    func accept<V: HTMLTagNameVisitor>(_ visitor: V) -> V.Result
    
    func isEqualTo(_ tagName: String) -> Bool
}

public extension HTMLTagName {
    func isEqualTo(_ tagName: String) -> Bool {
        return self.string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == tagName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
