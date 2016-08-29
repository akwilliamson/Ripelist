//
//  Your ListingDetailsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/1/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import LKAlertController
import ParseUI

protocol StoreListingEditsDelegate {
    func storeTitle(title: String)
    func storeDescription(description: String?)
    func storeImage(image: UIImage)
    func storePin(pin: PFGeoPoint)
}

class YourListingDetailsViewController: UIViewController, StoreListingEditsDelegate {
    
// MARK: - Properties
    
    let theAskingViewForLogin = "AttemptToContactLister"
    
    var localPost: LocalPost!
    var location: PFGeoPoint!
    var thumbnailImage: UIImageView?
    var timeAgoString: String!
    
// MARK: - Outlets
    
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swapTypeLabel1: UIInsetLabel!
    @IBOutlet weak var swapTypeLabel2: UIInsetLabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
// MARK: - View Setup
    
    override func viewDidLoad() {
        self.logEvents("Your Listings Details For Listing")
        // View Setup
        descriptionTextField.layer.borderColor = UIColor.forestColor().CGColor
        descriptionTextField.layer.borderWidth = 2
        // Content Setup
        populateImage()
        titleLabel.text = localPost.getTitle()
        populateSwapTypes()
        descriptionTextField.text = localPost.getDescription()
        timeAgoLabel.text = "posted: " + localPost.postObject.updatedAt!.timeAgoSinceDate()
        // If iPhone 4s, squeeze description details and minimize description/title font sizes
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 110
            descriptionTextField.font = UIFont.systemFontOfSize(14)
        } else {
            if strlen(titleLabel.text!) <= 24 {
                titleLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.currentUser() == nil {
            self.performSegueWithIdentifier("UnwindToPosts", sender: AnyObject?())
        } else {
            location = localPost.getLocation()
            configureMapView(location)
        }
    }
    
// MARK: - View Setup Helpers
    
    func populateImage() {
        guard let imageFile = localPost.getImageFile() else { self.listingImage.image = UIImage(named: "placeholder.png"); return }
        imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
            self.listingImage.image = UIImage(data: data!) ?? UIImage(named: "placeholder.png")
        })
    }
    
    func populateSwapTypes() {
        if let price = localPost.getPrice() {
            let amountType = localPost.getAmountType()
            swapTypeLabel2.text! = amountType == nil ? "$\(price)" : "$\(price)/\(amountType!)"
            
            if localPost.forTrade() { // For sale & trade
                swapTypeLabel1.text! = "Trade"
            } else { // Only for sale
                swapTypeLabel1.hidden = true
            }
            
        } else if localPost.forTrade() && localPost.forFree() {
            swapTypeLabel2.text! = "Trade"
            swapTypeLabel1.text! = "Free"
        } else if localPost.forTrade() {
            swapTypeLabel2.text! = "Trade"
            swapTypeLabel1.hidden = true
        } else { // for free
            swapTypeLabel2.text! = "Free"
            swapTypeLabel1.hidden = true
        }
    }
    
    func configureMapView(location: PFGeoPoint) {
        self.mapView.setRegion(latitude: location.latitude, longitude: location.longitude, atSpan: 0.01)
        self.mapView.addOverlay(latitude: location.latitude, longitude: location.longitude)
    }
    
// MARK: - Custom Delegate Methods
    
    func storeTitle(title: String) {
        titleLabel.text = title
    }

    func storeDescription(description: String?) {
        descriptionTextField.text = description
    }
    
    func storeImage(image: UIImage) {
        listingImage.image = image
    }
    
    func storePin(newLocation: PFGeoPoint) {
        location = newLocation
        configureMapView(location)
    }
    
// MARK: - Actions
    
    @IBAction func updateListing(sender: AnyObject) {
        let alert = Alert(title: "Refresh Listing", message: "This will refresh your post and move it to the top of the listings feed. Would you like to refresh?")
        alert.addAction("Yes", style: .Default) { action in
            self.localPost.postObject["updatedAt"] = NSDate()
            self.localPost.postObject.saveInBackground()
        }.addAction("No", style: .Cancel, handler: nil).show()
    }
    
// MARK: - Transitions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditListing" {
            let editListingVC = segue.destinationViewController as! EditListingViewController
            editListingVC.listingImage = listingImage
            editListingVC.listingDescription = localPost.getDescription()
            editListingVC.delegate = self
            editListingVC.listingObject = localPost.postObject
        }
    }
}

// MARK: - Protocol: MKMapView

extension YourListingDetailsViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = UIColor.purpleRadiusColor()
        return circle
    }
    
}
