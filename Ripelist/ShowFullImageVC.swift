//
//  ShowFullImageViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 5/29/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class ShowFullImageViewController: UIViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var listingImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvents("Show Full Listing Image")
        if let image = image { listingImage.image = image }
    }

    @IBAction func dismissButton(sender: AnyObject) {
        self.performSegueWithIdentifier("DismissPhotoView", sender: self)
    }
}
