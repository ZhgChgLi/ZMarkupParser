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
}
