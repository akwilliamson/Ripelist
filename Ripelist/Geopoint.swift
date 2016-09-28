//
//  Geopoint.swift
//  Ripelist
//
//  Created by Aaron Williamson on 9/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

extension PFGeoPoint {
    
    func setDistanceFromLabel(_ postLocationPoint: PFGeoPoint, currentLocationPoint: CLLocation) -> String {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            distanceFromLabel.font = UIFont(name: distanceFromLabel.font.fontName, size: 14)
            let currentLocation = PFGeoPoint(location: currentLocationPoint)
            var distanceBetweenPoints = postLocationPoint.distanceInMiles(to: currentLocation)
            distanceBetweenPoints = Double(round(100*distanceBetweenPoints)/100)
            switch distanceBetweenPoints {
            case 0...0.06:
                return "< 300 ft"
            case 0.06...0.08:
                return "< 400 ft"
            case 0.08...0.1:
                return "< 500 ft"
            case 0.1...0.11:
                return "< 600 ft"
            case 0.11...0.13:
                return "< 700 ft"
            case 0.13...0.15:
                return "< 800 ft"
            case 0.15...0.17:
                return "< 900 ft"
            case 0.17...0.19:
                return "< 1000 ft"
            default:
                distanceBetweenPoints = Double(round(10*distanceBetweenPoints)/10)
                return "\(distanceBetweenPoints) miles"
            }
        } else {
//            distanceFromLabel.numberOfLines = 2
//            distanceFromLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
//            distanceFromLabel.font = UIFont(name: distanceFromLabel.font.fontName, size: 7)
            return "Location disabled"
        }
    }
}
