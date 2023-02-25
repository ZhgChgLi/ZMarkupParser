//
//  HTMLSelector.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/17.
//

import Foundation

public class HTMLTagSelecor: HTMLSelector {
    public let tagName: String
    public let tagAttributedString: NSAttributedString
    public let attributes: [String: String]?
    
    init(tagName: String, tagAttributedString: NSAttributedString, attributes: [String : String]?) {
        self.tagName = tagName
        self.tagAttributedString = tagAttributedString
        self.attributes = attributes
    }
}

public class RawStringSelecor: HTMLSelector {
    let _attributedString: NSAttributedString
    
    init(attributedString: NSAttributedString) {
        self._attributedString = attributedString
    }
}

public class RootHTMLSelecor: HTMLSelector {
    
}

public class HTMLSelector {
    
    public private(set) weak var parentSelector: HTMLSelector? = nil
    public private(set) var childSelectors: [HTMLSelector] = []
    
    func appendChild(selector: HTMLSelector) {
        selector.parentSelector = self
        childSelectors.append(selector)
    }
    
    public func filter(_ htmlTagName: HTMLTagName) -> [HTMLTagSelecor] {
        return self.filter(htmlTagName.string)
    }
    
    public func filter(_ htmlTagName: WC3HTMLTagName) -> [HTMLTagSelecor] {
        return self.filter(htmlTagName.rawValue)
    }
    
    public func filter(_ htmlTagName: String) -> [HTMLTagSelecor] {
        return childSelectors.compactMap({ $0 as? HTMLTagSelecor }).filter({ $0.tagName == htmlTagName })
    }
    
    public func first(_ htmlTagName: WC3HTMLTagName) -> HTMLTagSelecor? {
        return self.filter(htmlTagName.rawValue).first
    }
    
    public func first(_ htmlTagName: HTMLTagName) -> HTMLTagSelecor? {
        return self.filter(htmlTagName).first
    }
    
    public func first(_ htmlTagName: String) -> HTMLTagSelecor? {
        return self.filter(htmlTagName).first
    }
}

extension HTMLSelector {
    public var attributedString: NSAttributedString {
        return attributedString(self)
    }
    
    private func attributedString(_ selector: HTMLSelector) -> NSAttributedString {
        if let contentSelector = selector as? RawStringSelecor {
            return contentSelector._attributedString
        } else {
            return selector.childSelectors.compactMap({ attributedString($0) }).reduce(NSMutableAttributedString()) { partialResult, attributedString in
                partialResult.append(attributedString)
                return partialResult
            }
        }
    }
}
