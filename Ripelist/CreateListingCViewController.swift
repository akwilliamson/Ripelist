//
//  CreateListingCViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import ParseUI
import Flurry_iOS_SDK

class CreateListingCViewController: UIViewController,
                                    MKMapViewDelegate {
    
// MARK: - Constants
    
    // Colors
    let        greenColor = UIColor.forestColor()
    let         goldColor = UIColor.goldColor()
    let    greenTextColor = UIColor.greenTextColor()
    let purpleRadiusColor = UIColor.purpleRadiusColor()

// MARK: - Variables
    
    var       listingTitle: String?
    var    listingCategory: String?
    var       listingPrice: String?
    var      listingAmount: String?
    var listingDescription: String?
    var      addressString: String?
    var            zipCode: String?
    var        homeAddress: String?
    var               name: String?
    var              image: UIImage?
    var        locationPin: MKPointAnnotation?
    var           forTrade: Bool?
    var            forFree: Bool?
    var           latitude: Double!
    var          longitude: Double!
    
// MARK: - Outlets
    
    // Views
    @IBOutlet weak var            userImage: UIImageView!
    @IBOutlet weak var           titleLabel: UILabel!
    @IBOutlet weak var       swapTypeLabel1: UILabel!
    @IBOutlet weak var       swapTypeLabel2: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var              mapView: MKMapView!
    @IBOutlet weak var     listingImageView: UIImageView!
    @IBOutlet weak var             userName: UIButton!
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Create Listing C")
        // To remove random white bar under the navigation bar
        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationController?.navigationBar.translucent = false
        // Get location from either address or pin and set up map view
        if homeAddress! != "" {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressString!, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let placemark = placemarks?[0] as CLPlacemark! {
                    let location = placemark.location!.coordinate
                    self.setUpMapView(location)
                }
            })
        } else {
            let location = locationPin!.coordinate
            setUpMapView(location)
        }
        // Show "no photo" if there' no photo
        if image == nil {
            listingImageView.image = UIImage(named: "placeholder.png")
        } else {
            listingImageView.image = image
        }
        setUIStyles()
        // Set up content
        titleLabel.text = listingTitle
        descriptionTextField.text = listingDescription
        
        if listingPrice! != "" {
            if listingAmount == "N/A" {
                swapTypeLabel1.hidden = true
                swapTypeLabel2.text = "$\(listingPrice!)  "
            } else {
                swapTypeLabel1.text = "$\(listingPrice!)/\(listingAmount!.lowercaseString)  "
            }
            if forTrade! == true {
                swapTypeLabel2.text = "Trade  "
            }
        } else if forTrade! == true {
            swapTypeLabel2.text = "Trade  "
            swapTypeLabel1.hidden = true
        } else {
            swapTypeLabel2.text = "Free  "
            swapTypeLabel1.hidden = true
        }
        userName.setTitle(name, forState: .Normal)
        // If iPhone 4s, squeeze description details and minimize description/title font sizes
        if self.view.frame.width == 320 {
            descriptionTextField.font = UIFont.systemFontOfSize(14)
        } else {
            if strlen(titleLabel.text!) <= 24 {
                titleLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
            }
        }
    }
    
    func setUIStyles() {
        listingImageView.layer.cornerRadius = 60
        listingImageView.clipsToBounds = true
        swapTypeLabel1.layer.cornerRadius = 13
        swapTypeLabel1.clipsToBounds = true
        swapTypeLabel1.textAlignment = .Center
        swapTypeLabel2.layer.cornerRadius = 13
        swapTypeLabel2.textAlignment = .Center
        swapTypeLabel2.clipsToBounds = true
        userImage.layer.cornerRadius = 18
        userImage.clipsToBounds = true
        listingImageView.clipsToBounds = true
        descriptionTextField.textColor = greenTextColor
        descriptionTextField.contentOffset = CGPointMake(0, -220)
    }
    
// MARK: - Custom Methods
    
    // Sets up map view on viewDidLoad
    func setUpMapView(locationCordinates: CLLocationCoordinate2D) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(locationCordinates, span)
        self.latitude = locationCordinates.latitude
        self.longitude = locationCordinates.longitude
        self.mapView.setRegion(region, animated: true)
        let locationForRadius = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        self.addRadiusCircle(locationForRadius)
    }
    // Helper to set up circle for map setup
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 300 as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
// MARK: - Mapview Delegate Methods
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = purpleRadiusColor
        return circle
    }
    
// MARK: - Actions
    
    @IBAction func submitListing(sender: AnyObject) {
        let listing = PFObject(className:"Listing")
            listing["title"]    = listingTitle
            listing["category"] = listingCategory
            listing["forFree"]  = forFree!
            listing["forTrade"] = forTrade!
            listing["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            listing["postType"] = "listing"
        if listingPrice != nil {
            listing["price"] = listingPrice
        } else {
            listing["price"] = NSNull()
        }
        if listingAmount != nil {
            listing["amountType"] = listingAmount?.lowercaseString
        } else {
            listing["amountType"] = NSNull()
        }
        if listingDescription != nil {
            listing["description"] = listingDescription
        } else {
            listing["description"] = NSNull()
        }
        if image != nil {
            let imageData = UIImagePNGRepresentation(image!)
            let imageFile = PFFile(name:"image.png", data:imageData!)
            listing["image"] = imageFile
        } else {
            listing["image"] = NSNull()
        }
        listing["owner"] = PFUser.currentUser()
        
        listing.saveInBackgroundWithBlock(nil)
        
        self.performSegueWithIdentifier("SubmitToPosts", sender: self)
    }
}
