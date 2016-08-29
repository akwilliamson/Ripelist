//
//  LoadingIndicator.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/17/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class LoadingIndicator: DTIActivityIndicatorView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        self.indicatorColor = UIColor.forestColor()
        self.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
    }
}
