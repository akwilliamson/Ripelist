//
//  CreateRequestCViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import ParseUI
import Flurry_iOS_SDK

class CreateRequestCViewController: UIViewController,
                                    MKMapViewDelegate {
    
// MARK: - Constants

    // Colors
    let greenColor = UIColor.forestColor()
    let greenTextColor = UIColor.greenTextColor()
    let purpleRadiusColor = UIColor.purpleRadiusColor()

// MARK: - Variables
    
    //
    var name: String?
    var requestTitle: String!
    var requestCategory: String!
    var requestSwapType: String!
    var requestDescription: String?
    var latitude: Double!
    var longitude: Double!
    var validAddress = false
    //
    var addressString: String?
    var zipCode: String?
    var homeAddress: String?
    var locationPin: MKPointAnnotation?
    
// MARK: - Outlets

    @IBOutlet weak var                image: UIImageView!
    @IBOutlet weak var        containerView: UIView!
    @IBOutlet weak var           titleLabel: UILabel!
    @IBOutlet weak var        swapTypeLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var              mapView: MKMapView!
    @IBOutlet weak var             userName: UIButton!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Create Request C")
        styleView()
        // To remove random white bar under the navigation bar
        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationController?.navigationBar.translucent = false
        
        let latitudeDelta: CLLocationDegrees = 0.01
        let longitudeDelta: CLLocationDegrees = 0.01
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        if homeAddress! != "" {
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(addressString!, completionHandler: { (placemarks: [CLPlacemark]?, error:NSError?) -> Void in
                if let placemark = placemarks?[0] as CLPlacemark? {
                    let location = placemark.location!.coordinate
                    self.latitude = placemark.location!.coordinate.latitude
                    self.longitude = placemark.location!.coordinate.longitude
                    let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                    self.mapView.setRegion(region, animated: false)
                    let locationForRadius = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
                    self.addRadiusCircle(locationForRadius)
                }
            })
        } else {
            let location = locationPin!.coordinate
            self.latitude = locationPin!.coordinate.latitude
            self.longitude = locationPin!.coordinate.longitude
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.mapView.setRegion(region, animated: true)
            let locationForRadius = CLLocation(latitude: latitude!, longitude: longitude!)
            addRadiusCircle(locationForRadius)
        }
        userName.setTitle(name, forState: .Normal)
        titleLabel.text = requestTitle
        swapTypeLabel.text = " \(requestSwapType)  "
        descriptionTextField.text = requestDescription
    }
    
    func styleView() {
        setTitleText()
        setUIStyles()
    }
    
    func setTitleText() {
        let navigationBar = navigationController?.navigationBar
        let fontSize = UIFont(name: "ArialRoundedMTBold", size: 25)!
        navigationBar?.titleTextAttributes = [NSFontAttributeName: fontSize, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func setUIStyles() {
        containerView.layer.cornerRadius = 60
        containerView.clipsToBounds = true
        image.layer.cornerRadius = 18
        image.clipsToBounds = true
        swapTypeLabel.layer.cornerRadius = 13
        swapTypeLabel.textAlignment = .Center
        swapTypeLabel.clipsToBounds = true
        descriptionTextField.textColor = greenTextColor
    }
    
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circleForCoordinates = MKCircle(centerCoordinate: location.coordinate, radius: 300 as CLLocationDistance)
        self.mapView.addOverlay(circleForCoordinates)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = MKCircleRenderer(overlay: overlay)
        circleOverlay.fillColor = purpleRadiusColor
        validAddress = true
        return circleOverlay
    }
    
    @IBAction func submitRequestButton(sender: AnyObject) {
        if validAddress == true {
            let listing = PFObject(className:"Listing")
            listing["title"] = requestTitle
            listing["category"] = requestCategory
            listing["swapType"] = requestSwapType
            listing["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            listing["postType"] = "request"
            if requestDescription != nil {
                listing["description"] = requestDescription
            } else {
                listing["description"] = NSNull()
            }
            listing["owner"] = PFUser.currentUser()
            listing.saveInBackgroundWithBlock(nil)
            self.performSegueWithIdentifier("SubmitToPosts", sender: self)
        } else {
            let alert = UIAlertController(title: "Invalid Location", message: "Please provide a valid location before submitting.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
