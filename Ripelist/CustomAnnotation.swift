//
//  CustomAnnotation.swift
//  Ripelist
//
//  Created by Aaron Williamson on 9/13/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI
import MapKit

class PostAnnotation: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var post: PFObject
    var imageFile: PFFile?
    
    init(title: String, coordinate: CLLocationCoordinate2D, post: PFObject, imageFile: PFFile?) {
        self.title = title
        self.coordinate = coordinate
        self.post = post
        self.imageFile = imageFile
    }
}