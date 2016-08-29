//
//  PostObject.swift
//  Ripelist
//
//  Created by Aaron Williamson on 12/7/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

class LocalPost {
    
    let postObject: PFObject
    let postAuthor: PFUser

    init(postObject: PFObject, postAuthor: PFUser) {
        self.postObject = postObject
        self.postAuthor = postAuthor
    }
    
    func getTitle() -> String {
        guard let title = postObject["title"] as? String else { return "No Title" }
        return title
    }
    
    func getDescription() -> String {
        guard let description = postObject["description"] as? String else { return "No description provided" }
        return description
    }
    
    func getUsername() -> String {
        guard let username = postAuthor["name"] as? String else { return "No username" }
        return username
    }
    
    func getSwapType() -> String {
        guard let swapType = postObject["swapType"] as? String else { return "N/A" }
        return swapType
    }
    
    func getImageFile() -> PFFile? {
        guard let imageFile = postObject["image"] as? PFFile else { return nil }
        return imageFile
    }
    
    func forSale() -> Bool {
        guard let price = postObject["price"] as? String else { return false }
        let forSale = price != "" && price != "0.00" ? true : false
        return forSale
    }
    
    func forTrade() -> Bool {
        guard let forTrade = postObject["forTrade"] as? Bool else { return false }
        return forTrade
    }
    
    func forFree() -> Bool {
        guard let forFree = postObject["forFree"] as? Bool else { return false }
        return forFree
    }
    
    func getAmountType() -> String? {
        guard let amountType = postObject["amountType"] as? String else { return nil }
        return amountType
    }
    
    func getPrice() -> String? {
        guard let price = postObject["price"] as? String else { return nil }
        return price == "" ? nil : price
    }
    
    func getPostType() -> String {
        return postObject["postType"] as! String
    }
    
    func getLocation() -> PFGeoPoint {
        return postObject["location"] as! PFGeoPoint
    }
    
    func getDistance(from currentLocation: CLLocation?) -> String {
        
        guard let postLocation = postObject["location"] as? PFGeoPoint else { return "No Location" }
        guard let currentLocation = currentLocation else { return "Location disabled" }
        
        let currentLocationPoint = PFGeoPoint(location: currentLocation)
        var distanceBetweenPoints = postLocation.distanceInMilesTo(currentLocationPoint)
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
    }
    
}