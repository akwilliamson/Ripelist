//
//  ListingCell.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

class ListingCell: PFTableViewCell {

    @IBOutlet weak var listingImageView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var forSaleLabel: UILabel!
    @IBOutlet weak var forTradeLabel: UILabel!
    @IBOutlet weak var forFreeLabel: UILabel!
    
    @IBOutlet weak var distanceAwayLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    internal func setTitle(withText text: String?) {
        if let text = text {
            self.titleLabel.text = text
        }
    }
    
    internal func setUsername(withText text: String?) {
        if let text = text {
            self.usernameLabel.text = text
        }
    }
    
    internal func setDistanceAway(fromPoint currentPoint: CLLocation?, toPoint postPoint: PFGeoPoint?) {
        if let currentPoint = currentPoint, let postGeoPoint = postPoint {
            let currentGeoPoint = PFGeoPoint(location: currentPoint)
            var distanceBetween = postGeoPoint.distanceInMiles(to: currentGeoPoint)
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
            distanceAwayLabel.lineBreakMode = .byWordWrapping
            distanceAwayLabel.text = "Location disabled"
        }
    }
}
