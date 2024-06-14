//
//  HTMLTagIdAttribute.swift
//
//
//  Created by zhgchgli on 2024/6/14.
//

import Foundation

public struct HTMLTagIdAttribute {
    public let idName: String
    public let render: (() -> (MarkupStyle?))
    
    public init(idName: String, render: @escaping (() -> (MarkupStyle?))) {
        self.idName = idName
        self.render = render
    }
    
    func isEqualTo(idName: String) -> Bool {
        return self.idName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == idName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
