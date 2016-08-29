//
//  UIView.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/23/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
}
