//
//  YourRequestDetailsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/31/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import LKAlertController
import ParseUI
import Flurry_iOS_SDK

protocol StoreRequestEditsDelegate {
    func storeTitle(_ title: String)
    func storeDescription(_ description: String?)
    func storePin(_ pin: PFGeoPoint)
}

class YourRequestDetailsViewController: UIViewController,
                                        MKMapViewDelegate,
                                        StoreRequestEditsDelegate {
    
// MARK: - Constants
    
    // Colors
    let        greenColor = UIColor.forestColor()
    let purpleRadiusColor = UIColor.purpleRadiusColor()
    let    greenTextColor = UIColor.greenTextColor()
    
// MARK: - Variables
    
    //
    var      requestObject: PFObject!
    var           location: PFGeoPoint!
    var    requestSwapType: String!
    var      timeAgoString: String!
    var            overlay: MKOverlay!
    
// MARK: - Outlets
    
    @IBOutlet weak var           titleLabel: UILabel!
    @IBOutlet weak var        swapTypeLabel: UILabel!
    @IBOutlet weak var         timeAgoLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var              mapView: MKMapView!
    
    @IBOutlet weak var    descriptionHeight: NSLayoutConstraint!
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Your Requests Details For Request")
        // View setup
               swapTypeLabel.layer.cornerRadius = 10
               swapTypeLabel.clipsToBounds = true
        descriptionTextField.textColor = greenTextColor
        descriptionTextField.layer.borderColor = greenColor.cgColor
        descriptionTextField.layer.borderWidth = 2
        // Content setup
                  titleLabel.text = requestObject["title"] as? String
               swapTypeLabel.text = requestSwapType
                timeAgoLabel.text = timeAgoString
        descriptionTextField.text = requestObject["description"] as? String
                         location = requestObject["location"] as! PFGeoPoint
        setUpMapView(location)
        // If iPhone 4s, squeeze description details and minimize description/title font sizes
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 110
            descriptionTextField.font = UIFont.systemFont(ofSize: 14)
        } else {
            if strlen(titleLabel.text!) <= 24 {
                titleLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.current() == nil {
            self.performSegue(withIdentifier: "UnwindToPosts", sender: AnyObject?())
        } else {
            location = requestObject["location"] as! PFGeoPoint
            setUpMapView(location)
        }
    }
    
// MARK: - Custom Delegate Methods
    
    func storeTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func storeDescription(_ description: String?) {
        descriptionTextField.text = description
    }
    
    func storePin(_ newLocation: PFGeoPoint) {
        setUpMapView(newLocation)
    }
    
    @IBAction func updateRequest(_ sender: AnyObject) {
        let alert = Alert(title: "Refresh Listing", message: "This will refresh your post and move it to the top of the listings feed. Would you like to refresh?")
        alert.addAction("Yes", style: .Default) { action in
            self.requestObject["updatedAt"] = NSDate()
            self.requestObject.saveInBackground()
            }.addAction("No", style: .Cancel, handler: nil).show()
    }
    
// MARK: - Custom Methods
    
    func addRadiusCircle(_ location: CLLocation){
        self.mapView.delegate = self
        if overlay != nil {
            self.mapView.remove(overlay)
        }
        let circle = MKCircle(center: location.coordinate, radius: 300 as CLLocationDistance)
        overlay = circle
        self.mapView.add(overlay)
    }
    
    func setUpMapView(_ newLocation: PFGeoPoint) {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
        self.mapView.setRegion(region, animated: false)
        let locationForRadius = CLLocation(latitude: location.latitude, longitude: location.longitude)
        addRadiusCircle(locationForRadius)
    }
    
// MARK: - Map View Delegate Methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = purpleRadiusColor
        return circle
    }
    
// MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditRequest" {
            let editRequestVC = segue.destination as! EditRequestViewController
            if let description = requestObject["description"] as? String {
                editRequestVC.requestObject = requestObject
                editRequestVC.delegate = self
                editRequestVC.requestDescription = description
            }
        }
    }
}
