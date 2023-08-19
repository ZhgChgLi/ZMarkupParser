//
//  MarkupStyleVendorColor.swift
//
//
//  Created by zhgchgli on 2023/8/15.
//

import Foundation

/// # If your project/product is using ZMarkupParser, feel free to create a PR (Pull Request) to add your brand and brand colors. :)
/// # Please also add your project/product to the "Who is using" section in the Readme file.
///
/// ## Tools:
/// Conver HEX String Color to RGB Online: https://www.colorhexa.com/ee847d
///

public enum MarkupStyleVendorColor {
    
    // == Pinkoi.com ==
    public enum PinkoiColor: CaseIterable {
        case nvay
        case salmon
        
        var rgb: (Int, Int, Int) {
            switch self {
            case .nvay:
                return (0,20,33)
            case .salmon:
                return (93,52,49)
            }
        }
    }
    case pinkoi(PinkoiColor)
    // == Pinkoi.com ==
    
    var rgb: (Int, Int, Int) {
        switch self {
        case .pinkoi(let color):
            return color.rgb
        }
    }
}
