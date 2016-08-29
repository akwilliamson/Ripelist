//
//  ViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/17/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI
import Flurry_iOS_SDK

extension UIViewController {
    
    func logEvents(eventString: String) {
        Flurry.logEvent(eventString)
    }
    
    func logEvents(eventString: String, withParameters parameters: [String: String], timed: Bool) {
        Flurry.logEvent(eventString, withParameters: parameters, timed: timed)
    }
    
    func createActivityVC(forPost postObject: PFObject) -> UIActivityViewController {
        
        let postTitle = postObject["title"] as! String, postImageFile = postObject["image"] as? PFFile
        
        let textToShare = SocialTextProvider(onPostWithTitle: postTitle)
        let imageToShare = SocialImageProvider(onPostWithImage: PFImageView(), file: postImageFile)
        
        let activityVC = UIActivityViewController(activityItems: [textToShare, imageToShare], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact]
        
        return activityVC
    }
    
}