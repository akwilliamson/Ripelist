//
//  CreateListingASetup.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/29/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

struct SetupViews {
    
    func setupSubViews(objects: [AnyObject!]) {
        for object in objects {
            object.layer.borderColor = UIColor.forestColor().CGColor
            object.layer.borderWidth = 2
            if object.isKindOfClass(UITextView) {
                object.layer.borderWidth = 1
            }
            if object.isKindOfClass(UIButton) {
                object.layer.cornerRadius = 10
            }
        }
    }
}