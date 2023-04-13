//
//  MarkupStyle+Extension.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/13.
//

import Foundation

public extension MarkupStyle {
    static let `default` = MarkupStyle(font: MarkupStyleFont(size: 12))
    static let bold = MarkupStyle(font: MarkupStyleFont(weight: .style(.semibold)))
    static let link = MarkupStyle(foregroundColor: MarkupStyleColor(color: .systemBlue), underlineStyle: .single)
    static let italic = MarkupStyle(font: MarkupStyleFont(italic: true))
    static let underline = MarkupStyle(underlineStyle: .single)
    static let deleteline = MarkupStyle(strikethroughStyle: .single)
    static let h1 = MarkupStyle(font: MarkupStyleFont(size: 24))
    static let h2 = MarkupStyle(font: MarkupStyleFont(size: 22))
    static let h3 = MarkupStyle(font: MarkupStyleFont(size: 20))
    static let h4 = MarkupStyle(font: MarkupStyleFont(size: 18))
    static let h5 = MarkupStyle(font: MarkupStyleFont(size: 16))
    static let h6 = MarkupStyle(font: MarkupStyleFont(size: 14))
    static let blockQuote = MarkupStyle(paragraphStyle: .init(headIndent: 10, firstLineHeadIndent: 10))
    static let code = MarkupStyle(paragraphStyle: .init(lineSpacing: 0, headIndent: 10, firstLineHeadIndent: 10), backgroundColor: .init(color: .lightGray))
}
