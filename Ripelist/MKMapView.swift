//
//  MKMapView.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/23/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import MapKit

extension MKMapView {

    func setRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees, atSpan span: CLLocationDegrees) {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinates, span)
        self.setRegion(region, animated: false)
    }
    
    func addOverlay(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let circleArea = MKCircle(center: location.coordinate, radius: 200 as CLLocationDistance)
        self.add(circleArea)
    }

}
