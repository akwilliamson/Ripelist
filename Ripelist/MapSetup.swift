//
//  MapSetup.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/28/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import MapKit

// Centers map over central portland with a certain zoom level

struct MapSetup {
    static let     span = MKCoordinateSpanMake(0.07, 0.07)
    static let location = CLLocationCoordinate2DMake(45.523457, -122.680512)
    static let   region = MKCoordinateRegionMake(location, span)
}