//
//  LocationService.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/13/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    
    private static var __once: () = {
            Static.instance = LocationService()
        }()
    
    class var sharedInstance: LocationService {
        struct Static {
            static var onceToken: Int = 0
            static var instance: LocationService? = nil
        }
        _ = LocationService.__once
        return Static.instance!
    }
    
    var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
}
