//
//  ParserProcessor.swift
//  
//
//  Created by https://zhgchg.li on 2023/2/9.
//

import Foundation

protocol ParserProcessor: AnyObject {
    associatedtype From
    associatedtype To
    
    func process(from: From) -> To
}
