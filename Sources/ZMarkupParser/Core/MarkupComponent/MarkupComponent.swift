//
//  MarkupComponent.swift
//  
//
//  Created by Harry Li on 2023/3/8.
//

import Foundation

protocol MarkupComponent {
    associatedtype T
    var markup: Markup { get }
    var value: T { get }
    
    init(markup: Markup, value: T)
}

extension Sequence where Iterator.Element: MarkupComponent {
    func value(markup: Markup) -> Element.T? {
        return self.first(where:{ $0.markup === markup })?.value as? Element.T
    }
}
