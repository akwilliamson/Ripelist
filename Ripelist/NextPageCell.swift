//
//  NextPageCell.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/17/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

class NextPageCell: PFTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.text = "Load More"
        self.textLabel?.textColor = UIColor.forestColor()
        self.textLabel?.textAlignment = .center
        self.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 25)
        self.tintColor = UIColor.forestColor()
    }
    
}
