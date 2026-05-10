//
//  ListIndexLookup.swift
//
//
//  Pre-computes per-`ListItemMarkup` topology (its immediate parent `ListMarkup`
//  and its sibling index) so list visitors avoid the per-item
//  `parent-chain walk + childMarkups.filter + firstIndex(where:)` pattern that
//  turned nested `<ol>` / `<ul>` rendering quadratic. See issue #89.
//

import Foundation

struct ListIndexLookup {
    let parentList: [ObjectIdentifier: ListMarkup]
    /// Zero-based position of each `ListItemMarkup` among its sibling list items
    /// (i.e. siblings that are also `ListItemMarkup`, ignoring any non-list-item
    /// nodes that may appear between them).
    let positionInList: [ObjectIdentifier: Int]

    static let empty = ListIndexLookup(parentList: [:], positionInList: [:])

    static func build(from root: Markup) -> ListIndexLookup {
        var parents: [ObjectIdentifier: ListMarkup] = [:]
        var positions: [ObjectIdentifier: Int] = [:]
        walk(root, parents: &parents, positions: &positions)
        return ListIndexLookup(parentList: parents, positionInList: positions)
    }

    private static func walk(
        _ markup: Markup,
        parents: inout [ObjectIdentifier: ListMarkup],
        positions: inout [ObjectIdentifier: Int]
    ) {
        if let list = markup as? ListMarkup {
            var pos = 0
            for child in list.childMarkups {
                if let li = child as? ListItemMarkup {
                    parents[ObjectIdentifier(li)] = list
                    positions[ObjectIdentifier(li)] = pos
                    pos += 1
                }
            }
        }
        for child in markup.childMarkups {
            walk(child, parents: &parents, positions: &positions)
        }
    }
}
