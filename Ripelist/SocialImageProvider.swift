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
    
    fileprivate var imageView: PFImageView
    fileprivate var file: PFFile?
    
    init(onPostWithImage imageView: PFImageView, file: PFFile?) {
        self.imageView = imageView
        self.file = file
        super.init(placeholderItem: imageView)
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        var image = UIImage(named: "logo.png")
        
        if file != nil {
            imageView.file = file
            imageView.load(inBackground: { (loadedImage, error) in
                image = loadedImage
            })
        }
        return image
    }
}
