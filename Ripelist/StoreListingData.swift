//
//  CreateListingBViewControllerDelegate.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/22/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import MapKit

/* 
   Stores a user's inputted address, zip code or location pin in order to prepopulate views when
   creating a listing regardless of whether they move forward or backward in the navigation stack.
*/

protocol CreateListingBViewControllerDelegate {
    func storeAddress(data: String?)
    func storeZip(data: String?)
    func storePin(data: MKPointAnnotation?)
    func storeImageView(data: UIImageView?)
}