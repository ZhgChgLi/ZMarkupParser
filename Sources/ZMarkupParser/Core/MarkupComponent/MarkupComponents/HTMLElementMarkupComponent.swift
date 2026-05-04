//
//  HTMLElementMarkupComponent.swift
//
//
//  Namespace for the parsed-HTML element value type that the
//  HTML pipeline associates with each Markup node via `MarkupIndex`.
//  The outer type is intentionally a caseless enum — there are
//  no instances; only the nested `HTMLElement` value is used.
//

import Foundation

enum HTMLElementMarkupComponent {
    struct HTMLElement {
        let tag: HTMLTag
        let tagAttributedString: NSAttributedString
        let attributes: [String: String]?
    }
}
