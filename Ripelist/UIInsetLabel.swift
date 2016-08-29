//
//  InsetLabel.swift
//  Ripelist
//
//  Created by Aaron Williamson on 12/12/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import UIKit

class UIInsetLabel: UILabel {
    
    let leftInset = CGFloat(5.0)
    let rightInset = CGFloat(5.0)
    
    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: rightInset)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize()
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}