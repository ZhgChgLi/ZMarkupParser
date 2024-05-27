//
//  File.swift
//  
//
//  Created by Lukas Gergel on 27.05.2024.
//

import Foundation

public struct MarkupStyleListStyle: MarkupStyleItem {
    public var listItemSpacing:CGFloat? = 4
    public var listIndent:CGFloat? = 16
    
    public init(listItemSpacing: CGFloat? = nil, listIndent: CGFloat? = nil) {
        self.listItemSpacing = listItemSpacing
        self.listIndent = listIndent
    }
    
    mutating func fillIfNil(from: MarkupStyleListStyle?) {
        self.listItemSpacing = self.listItemSpacing ?? from?.listItemSpacing
        self.listIndent = self.listIndent ?? from?.listIndent
    }
    
    func isNil() -> Bool {
        return !([listItemSpacing,listIndent] as [Any?]).contains(where: { $0 != nil})
    }
}
