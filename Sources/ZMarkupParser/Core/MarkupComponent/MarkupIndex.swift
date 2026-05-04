//
//  MarkupIndex.swift
//
//
//  O(1) lookup table keyed by Markup identity.
//
//  Replaces the previous `[MarkupComponent]` arrays whose
//  `Sequence.value(markup:)` extension performed an O(N) linear
//  scan, turning the per-render style resolution into O(N²·D).
//

import Foundation

struct MarkupIndex<Value> {
    private var storage: [ObjectIdentifier: Value] = [:]

    init() {}

    init(minimumCapacity: Int) {
        storage.reserveCapacity(minimumCapacity)
    }

    var isEmpty: Bool { storage.isEmpty }
    var count: Int { storage.count }

    mutating func set(_ value: Value, for markup: Markup) {
        storage[ObjectIdentifier(markup)] = value
    }

    mutating func reserveCapacity(_ minimumCapacity: Int) {
        storage.reserveCapacity(minimumCapacity)
    }

    func value(markup: Markup) -> Value? {
        return storage[ObjectIdentifier(markup)]
    }
}
