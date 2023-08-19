//
//  MarkupStyleSponsorColor.swift
//  
//
//  Created by zhgchgli on 2023/8/15.
//

import Foundation

/// # If this project has been helpful to you, I would greatly appreciate your support.
/// # If you're willing, you can consider buying me a cup of coffee as a token of encouragement.
/// # Thank you very much for your support!
/// ## Your brand and colors will be implemented here.
///
public enum MarkupStyleSponsorColor {
    
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
