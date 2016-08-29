//
//  SwapTypeDisplay.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/28/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

struct ConfigurePost {

    func setDistanceFromLabel(distanceFromLabel: UILabel,
                           postLocationPoint: PFGeoPoint,
                           currentLocationPoint: CLLocation) -> Void {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            distanceFromLabel.font = UIFont(name: distanceFromLabel.font.fontName, size: 14)
            let currentLocation = PFGeoPoint(location: currentLocationPoint)
            var distanceBetweenPoints = postLocationPoint.distanceInMilesTo(currentLocation)
            distanceBetweenPoints = Double(round(100*distanceBetweenPoints)/100)
            switch distanceBetweenPoints {
            case 0...0.06:
                distanceFromLabel.text = "< 300 ft"
            case 0.06...0.08:
                distanceFromLabel.text = "< 400 ft"
            case 0.08...0.1:
                distanceFromLabel.text = "< 500 ft"
            case 0.1...0.11:
                distanceFromLabel.text = "< 600 ft"
            case 0.11...0.13:
                distanceFromLabel.text = "< 700 ft"
            case 0.13...0.15:
                distanceFromLabel.text = "< 800 ft"
            case 0.15...0.17:
                distanceFromLabel.text = "< 900 ft"
            case 0.17...0.19:
                distanceFromLabel.text = "< 1000 ft"
            default:
                distanceBetweenPoints = Double(round(10*distanceBetweenPoints)/10)
                distanceFromLabel.text = "\(distanceBetweenPoints) miles"
            }
        } else {
            distanceFromLabel.numberOfLines = 2
            distanceFromLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            distanceFromLabel.text = "Location disabled"
        }
    }
    
}