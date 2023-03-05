//
//  IMG_HTMLTagName.swift
//  
//
//  Created by zhgchgli on 2023/3/1.
//

import Foundation
import ZNSTextAttachment

public struct IMG_HTMLTagName: HTMLTagName {
    public let string: String = WC3HTMLTagName.img.rawValue
    
    public weak var handler: ZNSTextAttachmentHandler?
    
    public init(handler: ZNSTextAttachmentHandler?) {
        self.handler = handler
    }
    
    public func accept<V>(_ visitor: V) -> V.Result where V : HTMLTagNameVisitor {
        return visitor.visit(self)
    }
}
