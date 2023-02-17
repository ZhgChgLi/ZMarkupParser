//
//  MarkupElementVisitor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/12.
//

import Foundation

protocol MarkupVisitor {
    associatedtype Result
        
    func visit(markup: Markup) -> Result
    
    func visit(_ markup: RootMarkup) -> Result
    func visit(_ markup: RawStringMarkup) -> Result
    func visit(_ markup: BreakLineMarkup) -> Result
    func visit(_ markup: ExtendMarkup) -> Result
    
    func visit(_ markup: UnorderListMarkup) -> Result
    func visit(_ markup: BoldMarkup) -> Result
    func visit(_ markup: HorizontalLineMarkup) -> Result
    func visit(_ markup: InlineMarkup) -> Result
    func visit(_ markup: ItalicMarkup) -> Result
    func visit(_ markup: LinkMarkup) -> Result
    func visit(_ markup: ListItemMarkup) -> Result
    func visit(_ markup: OrderListMarkup) -> Result
    func visit(_ markup: ParagraphMarkup) -> Result
    func visit(_ markup: UnderlineMarkup) -> Result
    func visit(_ markup: DeletelineMarkup) -> Result
}

extension MarkupVisitor {
    func visit(markup: Markup) -> Result {
        return markup.accept(self)
    }
}
