//
//  HTMLTagClassAttribute.swift
//
//
//  Created by zhgchgli on 2024/6/14.
//

import Foundation

public struct HTMLTagClassAttribute {
    public let className: String
    public let render: (() -> (MarkupStyle?))
    
    public init(className: String, render: @escaping (() -> (MarkupStyle?))) {
        self.className = className
        self.render = render
    }
    
    func isEqualTo(className: String) -> Bool {
        return self.className.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == className.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
