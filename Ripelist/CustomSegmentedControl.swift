//
//  CustomSegmentedControl.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            self.tintColor = UIColor.whiteColor()
        }
        super.touchesBegan(touches , withEvent:event)
    }
}