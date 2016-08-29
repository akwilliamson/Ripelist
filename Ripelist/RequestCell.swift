//
//  RequestCell.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/17/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

class RequestCell: PFTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swapTypeLabel: UILabel!
    
    @IBOutlet weak var distanceAwayLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor(red: 27/255, green: 166/255, blue: 0/255, alpha: 0.1)
    }
    
    internal func setTitle(withText text: String?) {
        if let text = text {
            self.titleLabel.text = text
        }
    }
    
    internal func setSwapType(withText text: String?) {
        if let text = text {
            self.swapTypeLabel.text = "\(text)  "
        }
    }
    
    internal func setUsername(withText text: String?) {
        if let text = text {
            self.usernameLabel.text = text
        }
    }
    
    internal func setDistanceAway(fromPoint currentPoint: CLLocation?, toPoint postPoint: PFGeoPoint?) {
        if let currentPoint = currentPoint, postGeoPoint = postPoint {
            let currentGeoPoint = PFGeoPoint(location: currentPoint)
            var distanceBetween = postGeoPoint.distanceInMilesTo(currentGeoPoint)
            distanceBetween = Double(round(100*distanceBetween)/100)
            switch distanceBetween {
            case 0...0.038:
                distanceAwayLabel.text = "< 200 ft"
            case 0.038...0.20:
                let distance = round(5280 * distanceBetween)
                let distanceText = String(format: "%.0f", distance)
                distanceAwayLabel.text = distanceText + " ft"
            default:
                let distanceText = String(format: "%.2f", distanceBetween)
                distanceAwayLabel.text = distanceText + " miles"
            }
        } else {
            distanceAwayLabel.numberOfLines = 2
            distanceAwayLabel.lineBreakMode = .ByWordWrapping
            distanceAwayLabel.text = "Location disabled"
        }
    }
}