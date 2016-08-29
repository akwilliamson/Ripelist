//
//  UIColor.swift
//  Ripelist
//
//  Created by Aaron Williamson on 7/6/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

extension UIColor {

    class func goldColor() -> UIColor {
        return UIColor(red:  250/255.0, green: 198/255.0, blue: 0/255.0, alpha: 1)
    }
    
    class func forestColor() -> UIColor {
        return UIColor(red:  102/255.0, green: 165/255.0, blue: 48/255.0, alpha: 1)
    }
    
    class func labelGreyColor() -> UIColor {
        return UIColor(red:  227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
    }
    
    class func purpleRadiusColor() -> UIColor {
        return UIColor(red:  136/255.0, green: 55/255.0, blue: 193/255.0, alpha: 0.4)
    }
    
    class func greenTextColor() -> UIColor {
        return UIColor(red:  73/255.0, green: 131/255.0, blue: 35/255.0, alpha: 1)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        
        let floatRed = CGFloat(r/255)
        let floatGreen = CGFloat(g/255)
        let floatBlue = CGFloat(b/255)
        
        self.init(red: floatRed, green: floatGreen, blue: floatBlue, alpha: 1.0)
    }
    
}