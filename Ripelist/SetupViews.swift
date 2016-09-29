//
//  CreateListingASetup.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/29/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

struct SetupViews {
    
    func setupSubViews(_ objects: [AnyObject?]) {
        for object in objects {
            object?.layer.borderColor = UIColor.forestColor().cgColor
            object?.layer.borderWidth = 2
            
            if object is UITextView {
                object?.layer.borderWidth = 1
            } else if object is UIButton {
                object?.layer.cornerRadius = 10
            }
        }
    }
}
