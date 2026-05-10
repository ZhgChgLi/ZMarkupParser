//
//  MarkupComponent.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation

protocol MarkupComponent {
    associatedtype T
    var markup: Markup { get }
    var value: T { get }
    
    init(markup: Markup, value: T)
}

extension Sequence where Iterator.Element: MarkupComponent {
    /// O(N) linear lookup. Prefer `buildLookup()` once and indexing the resulting dictionary
    /// when scanning many markups in a hot loop.
    func value(markup: Markup) -> Element.T? {
        return self.first(where:{ $0.markup === markup })?.value as? Element.T
    }

    /// Materialises an `ObjectIdentifier`-keyed dictionary so callers can convert the array's
    /// per-call O(N) `value(markup:)` into O(1) lookups across a render / visitor walk.
    func buildLookup() -> [ObjectIdentifier: Element.T] {
        var dict = [ObjectIdentifier: Element.T]()
        dict.reserveCapacity(underestimatedCount)
        for component in self {
            if let value = component.value as? Element.T {
                dict[ObjectIdentifier(component.markup)] = value
            }
        }
        return dict
    }
}

extension Dictionary where Key == ObjectIdentifier {
    @inline(__always)
    func value(markup: Markup) -> Value? {
        return self[ObjectIdentifier(markup)]
    }
}
