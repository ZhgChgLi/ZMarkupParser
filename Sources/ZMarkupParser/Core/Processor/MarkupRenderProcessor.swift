//
//  RootMarkupRenderProcessor.swift
//
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

final class MarkupRenderProcessor: ParserProcessor {
    typealias From = (Markup, [MarkupStyleComponent])
    typealias To = NSAttributedString

    let rootStyle: MarkupStyle?

    init(rootStyle: MarkupStyle?) {
        self.rootStyle = rootStyle
    }

    func process(from: From) -> To {
        let (root, components) = from
        // Precompute every markup's effective style top-down so the visitor's leaf-side
        // `collectMarkupStyle` becomes O(1) instead of O(depth) per leaf. The walker also folds
        // `rootStyle` into the seed inherited style, so the visitor never has to call
        // `fillIfNil(from: rootStyle)` per leaf.
        let lookup = components.buildLookup()
        var effectiveStyles: [ObjectIdentifier: MarkupStyle] = [:]
        effectiveStyles.reserveCapacity(max(64, lookup.count))
        precomputeStyles(root, inheritedStyle: rootStyle, lookup: lookup, into: &effectiveStyles)

        let visitor = MarkupNSAttributedStringVisitor(
            components: components,
            rootStyle: rootStyle,
            effectiveStyles: effectiveStyles
        )
        return visitor.visit(markup: root)
    }

    private func precomputeStyles(
        _ markup: Markup,
        inheritedStyle: MarkupStyle?,
        lookup: [ObjectIdentifier: MarkupStyle],
        into cache: inout [ObjectIdentifier: MarkupStyle]
    ) {
        let ownStyle = lookup.value(markup: markup)
        let merged: MarkupStyle?
        if var own = ownStyle, let parent = inheritedStyle {
            own.fillIfNil(from: parent)
            merged = own
        } else {
            merged = ownStyle ?? inheritedStyle
        }
        if let merged = merged {
            cache[ObjectIdentifier(markup)] = merged
        }
        for child in markup.childMarkups {
            precomputeStyles(child, inheritedStyle: merged, lookup: lookup, into: &cache)
        }
    }
}
