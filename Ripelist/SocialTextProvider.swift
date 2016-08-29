//
//  CustomActivityItemProvider.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class SocialTextProvider: UIActivityItemProvider {
    
    private var title: String
    
    init(onPostWithTitle title: String) {
        self.title = title
        super.init(placeholderItem: title)
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
        switch activityType {
        case UIActivityTypePostToTwitter:
            return "Found on Ripelist \(title) \(NSURL(string: "bit.ly/1LiLjMo")!)"
        case UIActivityTypeMail:
            return "\(title) \(NSURL(string: "bit.ly/1LiLjMo")!)"
        case UIActivityTypeMessage:
            return "\(title) \(NSURL(string: "bit.ly/1LiLjMo")!)"
        default:
            return nil
        }
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return "Ripelist - \(title)"
    }
    
}