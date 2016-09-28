//
//  CustomActivityItemProvider.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class SocialTextProvider: UIActivityItemProvider {
    
    fileprivate var title: String
    
    init(onPostWithTitle title: String) {
        self.title = title
        super.init(placeholderItem: title)
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        
        switch activityType {
        case UIActivityType.postToTwitter:
            return "Found on Ripelist \(title) \(URL(string: "bit.ly/1LiLjMo")!)"
        case UIActivityType.mail:
            return "\(title) \(URL(string: "bit.ly/1LiLjMo")!)"
        case UIActivityType.message:
            return "\(title) \(URL(string: "bit.ly/1LiLjMo")!)"
        default:
            return nil
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "Ripelist - \(title)"
    }
    
}
