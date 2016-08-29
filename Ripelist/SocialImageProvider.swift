//
//  SocialImageProvider.swift
//  Ripelist
//
//  Created by Aaron Williamson on 11/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation
import ParseUI

class SocialImageProvider: UIActivityItemProvider {
    
    private var imageView: PFImageView
    private var file: PFFile?
    
    init(onPostWithImage imageView: PFImageView, file: PFFile?) {
        self.imageView = imageView
        self.file = file
        super.init(placeholderItem: imageView)
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        var image = UIImage(named: "logo.png")
        
        if file != nil {
            imageView.file = file
            imageView.loadInBackground({ (loadedImage: UIImage?, error: NSError?) -> Void in
                image = loadedImage
            })
        }
        return image
    }
}