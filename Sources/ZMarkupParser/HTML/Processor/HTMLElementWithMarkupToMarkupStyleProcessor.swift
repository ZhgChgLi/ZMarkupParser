//
//  HTMLElementWithMarkupToMarkupStyleProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/8.
//

import Foundation

final class HTMLElementWithMarkupToMarkupStyleProcessor: ParserProcessor {
    typealias From = (Markup, [HTMLElementMarkupComponent])
    typealias To = [MarkupStyleComponent]
    
    let styleAttributes: [HTMLTagStyleAttribute]
    let classAttributes: [HTMLTagClassAttribute]
    let idAttributes: [HTMLTagIdAttribute]
    
    let policy: MarkupStylePolicy
    let rootStyle: MarkupStyle?
    init(styleAttributes: [HTMLTagStyleAttribute], classAttributes: [HTMLTagClassAttribute], idAttributes: [HTMLTagIdAttribute], policy: MarkupStylePolicy, rootStyle: MarkupStyle?) {
        self.styleAttributes = styleAttributes
        self.classAttributes = classAttributes
        self.idAttributes = idAttributes
        self.policy = policy
        self.rootStyle = rootStyle
    }
    
    func process(from: From) -> To {
        var components: [MarkupStyleComponent] = []
        let visitor = HTMLElementMarkupComponentMarkupStyleVisitor(policy: policy, components: from.1, styleAttributes: styleAttributes, classAttributes: classAttributes, idAttributes: idAttributes, rootStyle: rootStyle)
        walk(markup: from.0, visitor: visitor, components: &components)
        return components
    }
    
    func walk(markup: Markup, visitor: HTMLElementMarkupComponentMarkupStyleVisitor, components: inout [MarkupStyleComponent]) {
        
        if let markupStyle = visitor.visit(markup: markup) {
            components.append(.init(markup: markup, value: markupStyle))
        }
        
        for markup in markup.childMarkups {
            walk(markup: markup, visitor: visitor, components: &components)
        }
    }
}
