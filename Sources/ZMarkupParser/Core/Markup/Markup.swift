//
//  Markup.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/9.
//

import Foundation

protocol Markup: AnyObject {
    var parentMarkup: Markup? { get set }
    var childMarkups: [Markup] { get set }
    var style: MarkupStyle? { get }
    
    func appendChild(markup: Markup)
    func prependChild(markup: Markup)
    func accept<V: MarkupVisitor>(_ visitor: V) -> V.Result
}

extension Markup {
    func appendChild(markup: Markup) {
        markup.parentMarkup = self
        childMarkups.append(markup)
    }
    
    func prependChild(markup: Markup) {
        markup.parentMarkup = self
        childMarkups.insert(markup, at: 0)
    }
}
