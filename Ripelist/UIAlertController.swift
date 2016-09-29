//
//  CustomAlerts.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/22/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

// This extension adds custom alerts that are presented more than once throughout the application.

extension UIAlertController {
    class func failedLoginOrSignupNotice(_ title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
            style: .cancel,
            handler: nil))
        
        return controller
    }
    
    class func invalidFieldAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Invalid Field",
                                           message: "Please add a title, category and swap type before continuing.",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
                                           style: .default,
                                           handler: nil))
        return controller
    }
    
    class func possibleFeatureAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Bookmarked Posts",
            message: "A feature to see posts you've saved. Should we build it?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes build it now!", style: .default) { action in
            let feedback = PFObject(className: "Feedback")
            feedback["bookmarkedPosts"] = true
            feedback["user"] = PFUser.current()
            feedback.saveInBackground()
        }
        let noAction = UIAlertAction(title: "Not that important", style: .default) { action in
            let feedback = PFObject(className: "Feedback")
            feedback["bookmarkedPosts"] = false
            feedback["user"] = PFUser.current()
            feedback.saveInBackground()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        controller.addAction(yesAction)
        controller.addAction(noAction)
        controller.addAction(cancelAction)

        return controller
    }
    
    class func photoCouldNotBeSavedAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Save Failed",
                                         message: "Photo could not be saved.",
                                  preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
                                           style: .default,
                                         handler: nil))
        return controller
    }
    
    class func chooseCategoryAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Choose Category",
                                           message: "\n\n\n\n\n\n\n\n\n\n",
                                           preferredStyle: .actionSheet)
        
        controller.view.tintColor = UIColor.forestColor()
        controller.view.backgroundColor = UIColor.white
        
        return controller
    }
    
    class func chooseSwapTypeAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Choose Swap Type",
                                           message: "\n\n\n\n\n\n\n\n\n\n",
                                           preferredStyle: .actionSheet)
     
        controller.view.tintColor = UIColor.forestColor()
        controller.view.backgroundColor = UIColor.white
        
        return controller
    }
    
    class func invalidAddressAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Invalid Location",
                                           message: "Please provide an address or location before continuing.",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
                                           style: .cancel,
                                           handler: nil))
        return controller
    }
    
    class func invalidZipAlertController() -> UIAlertController {
        let controller = UIAlertController(title: "Invalid Zip Code",
                                           message: "Please provide a valid zip code before continuing.",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
                                           style: .cancel,
                                           handler: nil))
        return controller
    }
    
    class func cannotMessageYourselfController() -> UIAlertController {
        let controller = UIAlertController(title: "Wait a Minute...",
                                           message: "No need to message yourself!",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Dismiss",
                                           style: .cancel,
                                           handler: nil))
        return controller
    }
    
}
