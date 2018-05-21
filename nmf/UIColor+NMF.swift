//
//  UIColor+NMF.swift
//  nmf
//
//  Created by Ben Lachman on 5/27/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit

// Note: Tab bar color is set as a "User Defined Runtime Attribute" in Main.storyboard

extension UIColor {
    class func mapBackgroundColor() -> UIColor {
        return UIColor(red:0.839, green:0.722, blue:0.588, alpha:1.000) // tan bg
    }
    
    class func scheduleTextColor() -> UIColor {
        return UIColor.white
        //UIColor(red:0.976, green:0.969, blue:0.792, alpha:1.000) // light cream text
    }
    
    class func hightlightColor() -> UIColor {
        //        return UIColor(red:0.827, green:0.263, blue:0.255, alpha:1.000) // coral
        return UIColor(red:0.573, green:0.714, blue:0.329, alpha:1.000) // light green
    }
    
    class func charcoal() -> UIColor {
        return UIColor(white:0.102, alpha:1.000) // charcoal
    }
    
    class func lightCharcoal() -> UIColor {
        return UIColor(white:0.122, alpha:1.000) // lighter charcoal
    }
}
