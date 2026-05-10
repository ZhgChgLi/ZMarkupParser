//
//  HTMLElementMarkupComponentMarkupStyleVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum MarkupStylePolicy {
    case respectMarkupStyleFromCode
    case respectMarkupStyleFromHTMLStyleAttribute
}

struct HTMLElementMarkupComponentMarkupStyleVisitor: MarkupVisitor {

    typealias Result = MarkupStyle?
    
    let policy: MarkupStylePolicy
    let components: [HTMLElementMarkupComponent]
    /// O(1) per-markup lookup of the same data as `components`; built once on init so the
    /// visitor's per-element `componentsLookup.value(markup:)` runs in constant time instead of
    /// the legacy O(N) `Array.first(where:)` scan (rendering an N-node tree was O(N^2)).
    let componentsLookup: [ObjectIdentifier: HTMLElementMarkupComponent.HTMLElement]
    let styleAttributes: [HTMLTagStyleAttribute]
    let classAttributes: [HTMLTagClassAttribute]
    let idAttributes: [HTMLTagIdAttribute]

    let rootStyle: MarkupStyle?

    /// Pre-built `ListItemMarkup` -> `(parent ListMarkup, sibling index)` table.
    /// Built once per `process` pass so list-item style computation is O(1) per item
    /// instead of O(N) per item / O(N^2) per list (issue #89).
    let listLookup: ListIndexLookup

    /// Memoises `visit(_ ListItemMarkup)` results so the recursive grandparent visit
    /// inside that method (and any visits triggered by `collectMarkupStyle`) collapse
    /// from exponential to linear total work for deeply nested lists. Class-backed so
    /// the struct visitor can mutate it in place.
    private let listItemStyleMemo: _ListItemStyleMemo

    init(
        policy: MarkupStylePolicy,
        components: [HTMLElementMarkupComponent],
        styleAttributes: [HTMLTagStyleAttribute],
        classAttributes: [HTMLTagClassAttribute],
        idAttributes: [HTMLTagIdAttribute],
        rootStyle: MarkupStyle?,
        listLookup: ListIndexLookup = .empty
    ) {
        self.policy = policy
        self.components = components
        self.componentsLookup = components.buildLookup()
        self.styleAttributes = styleAttributes
        self.classAttributes = classAttributes
        self.idAttributes = idAttributes
        self.rootStyle = rootStyle
        self.listLookup = listLookup
        self.listItemStyleMemo = _ListItemStyleMemo()
    }
    
    func visit(_ markup: RootMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: RawStringMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: BreakLineMarkup) -> Result {
        return nil
    }
    
    func visit(_ markup: ExtendMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: BoldMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .bold)
    }
    
    func visit(_ markup: HorizontalLineMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: InlineMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: ColorMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: MarkupStyle(foregroundColor: markup.color))
    }
    
    func visit(_ markup: ItalicMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .italic)
    }
    
    func visit(_ markup: LinkMarkup) -> Result {
        var markupStyle = defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .link) ?? .link
        if let href = componentsLookup.value(markup: markup)?.attributes?["href"] as? String,
           let url = URL(string: href) {
            markupStyle.link = url
        }
        return markupStyle
    }
    
    func visit(_ markup: ListMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: ListItemMarkup) -> Result {
        // Hot path for issue #89: memoised so the recursive `visit(markup: ancestorLi)`
        // calls below — and any further re-entry triggered by `collectMarkupStyle`'s
        // parent-chain walk — fold into O(1) cache hits. The walker visits ancestors
        // before descendants, so by the time a deeper li is computed every ancestor li
        // is already cached.
        if let cached = listItemStyleMemo.value(for: markup) {
            return cached
        }

        var defaultStyle = defaultVisit(componentsLookup.value(markup: markup)) ?? MarkupStyle()

        // O(1) parent-list resolution via the precomputed lookup; the legacy parent-chain
        // walk is kept only as a fallback for callers that built the visitor without a
        // lookup (direct test instantiations).
        let parentListMarkup: ListMarkup? = listLookup.parentList[ObjectIdentifier(markup)] ?? {
            var currentMarkup: Markup? = markup.parentMarkup
            while let thisMarkup = currentMarkup {
                if let listMarkup = thisMarkup as? ListMarkup {
                    return listMarkup
                }
                currentMarkup = thisMarkup.parentMarkup
            }
            return nil
        }()

        guard let parentListMarkup = parentListMarkup else {
            listItemStyleMemo.cache(defaultStyle, for: markup)
            return defaultStyle
        }

        // Parent ListMarkup's own styling — `visit(_: ListMarkup)` is a thin call to
        // `defaultVisit`, no further recursion.
        let listStyleType: MarkupStyleType = visit(parentListMarkup)?.paragraphStyle.textListStyleType ?? .disc

        // Nearest ancestor list item — recursion is safe because (a) the walker is
        // top-down so ancestors are typically already memoised, and (b) the memo above
        // ensures any first-time chain is O(depth) overall, not exponential.
        var parentIndent: CGFloat?
        var ancestor: Markup? = parentListMarkup.parentMarkup
        while let thisMarkup = ancestor {
            if let ancestorLi = thisMarkup as? ListItemMarkup {
                parentIndent = visit(ancestorLi)?.paragraphStyle.headIndent ?? 0
                break
            }
            ancestor = thisMarkup.parentMarkup
        }

        let item: String
        if listStyleType.isOrder() {
            let zeroBased = listLookup.positionInList[ObjectIdentifier(markup)] ?? {
                let siblingListItems = parentListMarkup.childMarkups.filter({ $0 is ListItemMarkup })
                return siblingListItems.firstIndex(where: { $0 === markup }) ?? 0
            }()
            let position = zeroBased + parentListMarkup.startingItemNumber
            item = listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: position)
        } else {
            item = listStyleType.getItem(startingItemNumber: parentListMarkup.startingItemNumber, forItemNumber: parentListMarkup.startingItemNumber)
        }

        let inheritStyle = collectMarkupStyle(markup, defaultStyle: defaultStyle) ?? defaultStyle

        let headIndent: CGFloat
        if let parentIndent = parentIndent, parentIndent > 0 {
            headIndent = parentIndent
        } else {
            headIndent = inheritStyle.paragraphStyle.textListHeadIndent ?? 4
        }

        let indent = inheritStyle.paragraphStyle.textListIndent ?? 8

        let itemWidth: CGFloat
        if inheritStyle.font.size != nil {
            itemWidth = inheritStyle.font.sizeOf(string: item)?.width ?? 4
        } else {
            itemWidth = ceil(MarkupStyle.default.font.sizeOf(string: item)?.width ?? 4)
        }

        var tabStops: [NSTextTab] = [.init(textAlignment: .left, location: headIndent)]
        tabStops.append(.init(textAlignment: .left, location: headIndent + itemWidth + indent))

        defaultStyle.paragraphStyle.defaultTabInterval = defaultStyle.paragraphStyle.defaultTabInterval ?? 28
        defaultStyle.paragraphStyle.tabStops = defaultStyle.paragraphStyle.tabStops ?? tabStops
        defaultStyle.paragraphStyle.headIndent = defaultStyle.paragraphStyle.headIndent ?? defaultStyle.paragraphStyle.tabStops?.last?.location

        listItemStyleMemo.cache(defaultStyle, for: markup)
        return defaultStyle
    }
    
    func visit(_ markup: ParagraphMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: UnderlineMarkup) -> Result {
        let htmlElement = componentsLookup.value(markup: markup)
        return defaultVisit(htmlElement, defaultStyle: .underline)
    }
    
    func visit(_ markup: DeletelineMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .deleteline)
    }
    
    func visit(_ markup: TableMarkup) -> MarkupStyle? {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: TableRowMarkup) -> Result {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: HeadMarkup) -> Result {
        let defaultStyle: MarkupStyle?
        switch markup.level {
        case .h1:
            defaultStyle = .h1
        case .h2:
            defaultStyle = .h2
        case .h3:
            defaultStyle = .h3
        case .h4:
            defaultStyle = .h4
        case .h5:
            defaultStyle = .h5
        case .h6:
            defaultStyle = .h6
        }
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: defaultStyle)
    }
    
    func visit(_ markup: TableColumnMarkup) -> Result {
        let htmlElement = componentsLookup.value(markup: markup)
        if markup.isHeader {
            return defaultVisit(htmlElement, defaultStyle: .bold)
        } else {
            return defaultVisit(htmlElement)
        }
    }
    
    func visit(_ markup: ImageMarkup) -> MarkupStyle? {
        return defaultVisit(componentsLookup.value(markup: markup))
    }
    
    func visit(_ markup: BlockQuoteMarkup) -> MarkupStyle? {
        return  defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .blockQuote)
    }
    
    func visit(_ markup: CodeMarkup) -> MarkupStyle? {
        return defaultVisit(componentsLookup.value(markup: markup), defaultStyle: .code)
    }
}

extension HTMLElementMarkupComponentMarkupStyleVisitor {
    private func customStyle(_ htmlElement: HTMLElementMarkupComponent.HTMLElement?) -> MarkupStyle? {
        guard let customStyle = htmlElement?.tag.customStyle else {
            return nil
        }
        return customStyle
    }
    
    private func collectMarkupStyle(_ markup: Markup, defaultStyle: MarkupStyle? = nil) -> MarkupStyle? {
        // collect from upstream
        // String("Test") -> Bold -> Italic -> Root
        // Result: style: Bold+Italic
        
        var currentMarkup: Markup? = markup.parentMarkup
        var currentStyle = defaultStyle
        while let thisMarkup = currentMarkup {
            guard let thisMarkupStyle = visit(markup: thisMarkup) else {
                currentMarkup = thisMarkup.parentMarkup
                continue
            }

            if var thisCurrentStyle = currentStyle {
                thisCurrentStyle.fillIfNil(from: thisMarkupStyle)
                currentStyle = thisCurrentStyle
            } else {
                currentStyle = thisMarkupStyle
            }

            currentMarkup = thisMarkup.parentMarkup
        }
        
        if var currentStyle = currentStyle {
            currentStyle.fillIfNil(from: rootStyle)
            return currentStyle
        } else {
            return rootStyle
        }
    }
    
    func defaultVisit(_ htmlElement: HTMLElementMarkupComponent.HTMLElement?, defaultStyle: MarkupStyle? = nil) -> Result {
        
        var markupStyle: MarkupStyle? = nil
        if let customStyle = customStyle(htmlElement) {
            // has custom style
            markupStyle = customStyle
        }
        
        // id
        if let idString = htmlElement?.attributes?["id"],
           let idAttribute = idAttributes.first(where: { $0.isEqualTo(idName: idString) }),
           var thisMarkupStyle = idAttribute.render() {
            switch policy {
            case .respectMarkupStyleFromCode:
                if var markupStyle = markupStyle {
                    markupStyle.fillIfNil(from: thisMarkupStyle)
                } else {
                    markupStyle = thisMarkupStyle
                }
            case .respectMarkupStyleFromHTMLStyleAttribute:
                thisMarkupStyle.fillIfNil(from: markupStyle ?? defaultStyle)
                markupStyle = thisMarkupStyle
            }
        }
        // class
        if let classString = htmlElement?.attributes?["class"],
           classAttributes.count > 0 {
            let classNames = classString.split(separator: " ").filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
            
            for className in classNames {
                if let classAttribute = classAttributes.first(where: { $0.isEqualTo(className: String(className)) }),
                   var thisMarkupStyle = classAttribute.render() {
                    switch policy {
                    case .respectMarkupStyleFromCode:
                        if var markupStyle = markupStyle {
                            markupStyle.fillIfNil(from: thisMarkupStyle)
                        } else {
                            markupStyle = thisMarkupStyle
                        }
                    case .respectMarkupStyleFromHTMLStyleAttribute:
                        thisMarkupStyle.fillIfNil(from: markupStyle ?? defaultStyle)
                        markupStyle = thisMarkupStyle
                    }
                }
            }
        }
        // style
        if let styleString = htmlElement?.attributes?["style"],
              styleAttributes.count > 0 {
            let styles = styleString.split(separator: ";").filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }.map { $0.split(separator: ":") }
            
            for style in styles {
                guard style.count == 2 else {
                    continue
                }
                
                let key = style[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = style[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let styleAttribute = styleAttributes.first(where: { $0.isEqualTo(styleName: key) }) {
                    let visitor = HTMLTagStyleAttributeToMarkupStyleVisitor(value: value)
                    if var thisMarkupStyle = visitor.visit(styleAttribute: styleAttribute) {
                        switch policy {
                        case .respectMarkupStyleFromCode:
                            if var markupStyle = markupStyle {
                                markupStyle.fillIfNil(from: thisMarkupStyle)
                            } else {
                                markupStyle = thisMarkupStyle
                            }
                        case .respectMarkupStyleFromHTMLStyleAttribute:
                            thisMarkupStyle.fillIfNil(from: markupStyle ?? defaultStyle)
                            markupStyle = thisMarkupStyle
                        }
                    }
                }
            }
        }
        
        return markupStyle ?? defaultStyle
    }
}

/// Per-`process` cache for `visit(_ ListItemMarkup)` results. A reference type so the
/// surrounding struct visitor can record memoised values without itself becoming `var`.
final class _ListItemStyleMemo {
    private var storage: [ObjectIdentifier: MarkupStyle] = [:]

    func value(for markup: ListItemMarkup) -> MarkupStyle? {
        return storage[ObjectIdentifier(markup)]
    }

    func cache(_ style: MarkupStyle, for markup: ListItemMarkup) {
        storage[ObjectIdentifier(markup)] = style
    }
}
