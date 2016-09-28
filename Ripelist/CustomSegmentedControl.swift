//
//  CustomSegmentedControl.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.sendActions(for: UIControlEvents.valueChanged)
            self.tintColor = UIColor.white
        }
        super.touchesBegan(touches , with:event)
    }
}
