//
//  ZHTMLParser+AttributedString.swift
//
//
//  Bridges `ZHTMLParser`'s existing `NSAttributedString` rendering pipeline to
//  Foundation's value-type `AttributedString` (iOS 15+ / macOS 12+), so SwiftUI
//  callers can write `Text(parser.attributedString(html))` directly instead of
//  hand-wrapping `AttributedString(parser.render(html))` everywhere.
//
//  Implementation note: this is a thin wrapper that calls the existing
//  `render(_:)` family and feeds the result into `AttributedString.init(_:)`.
//  Foundation's initialiser maps the standard attribute keys (font, color,
//  link, underline, paragraph style, attachment, …) through its built-in
//  Foundation / UIKit / AppKit / SwiftUI scopes — i.e. every attribute the
//  parser actually emits — so a separate native `AttributedString` visitor
//  isn't worth maintaining.
//

import Foundation

@available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
public extension ZHTMLParser {

    func attributedString(_ string: String, forceDecodeHTMLEntities: Bool = true) -> AttributedString {
        return AttributedString(self.render(string, forceDecodeHTMLEntities: forceDecodeHTMLEntities))
    }

    func attributedString(_ attributedString: NSAttributedString, forceDecodeHTMLEntities: Bool = true) -> AttributedString {
        return AttributedString(self.render(attributedString, forceDecodeHTMLEntities: forceDecodeHTMLEntities))
    }

    func attributedString(_ selector: HTMLSelector) -> AttributedString {
        return AttributedString(self.render(selector))
    }

    func attributedString(_ string: String, forceDecodeHTMLEntities: Bool = true, completionHandler: @escaping (AttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let result = self.attributedString(string, forceDecodeHTMLEntities: forceDecodeHTMLEntities)
            DispatchQueue.main.async { completionHandler(result) }
        }
    }

    func attributedString(_ attributedString: NSAttributedString, forceDecodeHTMLEntities: Bool = true, completionHandler: @escaping (AttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let result = self.attributedString(attributedString, forceDecodeHTMLEntities: forceDecodeHTMLEntities)
            DispatchQueue.main.async { completionHandler(result) }
        }
    }

    func attributedString(_ selector: HTMLSelector, completionHandler: @escaping (AttributedString) -> Void) {
        ZHTMLParser.dispatchQueue.async {
            let result = self.attributedString(selector)
            DispatchQueue.main.async { completionHandler(result) }
        }
    }
}
