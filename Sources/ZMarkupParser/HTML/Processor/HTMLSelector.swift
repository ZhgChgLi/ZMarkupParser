//
//  HTMLSelector.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/17.
//

import Foundation

public class HTMLSelector: CustomStringConvertible {
    
    let markup: Markup
    let componets: [HTMLElementMarkupComponent]
    init(markup: Markup, componets: [HTMLElementMarkupComponent]) {
        self.markup = markup
        self.componets = componets
    }
    
    public var description: String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self._get(markup: markup, attributedString: false), options: .prettyPrinted) else {
            return "HTMLSelector"
        }
        return String(data: jsonData, encoding: .utf8) ?? "HTMLSelector"
    }
    
    public var attributedString: NSAttributedString {
        return MarkupStripperProcessor().process(from: markup)
    }
    
    public func filter(_ htmlTagName: HTMLTagName) -> [HTMLSelector] {
        return self.filter(htmlTagName.string)
    }
    
    public func filter(_ htmlTagName: WC3HTMLTagName) -> [HTMLSelector] {
        return self.filter(htmlTagName.rawValue)
    }
    
    public func filter(_ htmlTagName: String) -> [HTMLSelector] {
        let result = markup.childMarkups.filter({ componets.value(markup: $0)?.tag.tagName.isEqualTo(htmlTagName) ?? false })
        return result.map({ .init(markup: $0, componets: componets) })
    }
    
    public func first(_ htmlTagName: WC3HTMLTagName) -> HTMLSelector? {
        return self.filter(htmlTagName.rawValue).first
    }
    
    public func first(_ htmlTagName: HTMLTagName) -> HTMLSelector? {
        return self.filter(htmlTagName).first
    }
    
    public func first(_ htmlTagName: String) -> HTMLSelector? {
        return self.filter(htmlTagName).first
    }
    
    public func get() -> [String: Any] {
        return _get(markup: markup, attributedString: true)
        
    }
    
    private func _get(markup: Markup, attributedString: Bool) -> [String: Any] {
        let dict = convertToDict(from: markup, attributedString: attributedString)
        return markup.childMarkups.reduce(dict) { partialResult, childMarkup in
            var newPartialResult = partialResult
            var childs: [[String: Any]] = (newPartialResult["childs"] as? [[String: Any]]) ?? []
            childs.append(_get(markup: childMarkup, attributedString: attributedString))
            newPartialResult["childs"] = childs
            return newPartialResult
        }
    }
    
    private func convertToDict(from markup: Markup, attributedString: Bool) -> [String: Any] {
        if let rawStringMarkup = markup as? RawStringMarkup {
            return [
                "type": "string",
                "value": (attributedString) ? (rawStringMarkup.attributedString) : (rawStringMarkup.attributedString.string)
            ]
        } else if let htmlElement = componets.value(markup: markup) {
            return [
                "type": "tag",
                "name": htmlElement.tag.tagName.string,
                "value": (attributedString) ? (htmlElement.tagAttributedString) : (htmlElement.tagAttributedString.string),
                "attributes": htmlElement.attributes as Any
            ]
        } else {
            return [:]
        }
    }
}
