//
//  UIColor+AppColors.swift
//  BullionStacker
//
//  Created by Lloyd Luck on 3/22/15.
//  Copyright (c) 2015 Lloyd Luck. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func positiveColor() -> UIColor {
        // 34-139-34
        return UIColor(red: (0/255), green: (185/255), blue: (0/255), alpha: 1.0)
    }
    
    class func negativeColor() -> UIColor {
        // 168-0-0
        return UIColor(red: (168/255), green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    class func lightSilverColor() -> UIColor {
        return UIColor(red: (237/255), green: (237/255), blue: (237/255), alpha: 1.0)
    }
    
    class func darkSilverColor() -> UIColor {
        return UIColor(red: (222/255), green: (222/255), blue: (222/255), alpha: 1.0)
    }
    
    class func lightGoldColor() -> UIColor {
        return UIColor(red: (238/255), green: (220/255), blue: (198/255), alpha: 1.0)
    }
    
    class func darkGoldColor() -> UIColor {
        return UIColor(red: (223/255), green: (205/255), blue: (183/255), alpha: 1.0)
    }
    
    class func disabledColor() -> UIColor {
        return UIColor.black.withAlphaComponent(0.1)
    }
   
}
