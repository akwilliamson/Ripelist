//
//  EditListingLocationViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import ParseUI
import Flurry_iOS_SDK

class EditListingLocationViewController: UIViewController,
                                         MKMapViewDelegate,
                                         CLLocationManagerDelegate {
    
    let greenColor = UIColor.forestColor()
    var newPin = MKPointAnnotation()
    var delegate: StoreListingEditsDelegate?
    var listingObject: PFObject!    

// MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Listing Location")
        // Navigation bar title
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        saveButton.layer.cornerRadius = 25
        
        // Map setup
        mapView.delegate = self
        
        let locationGeoPoint = listingObject["location"] as! PFGeoPoint
        setUpMapView(locationGeoPoint)
        let coordinates = CLLocationCoordinate2DMake(locationGeoPoint.latitude, locationGeoPoint.longitude)
        newPin.coordinate = coordinates
        
        mapView.addAnnotation(newPin)

        let tapToAddPin = UILongPressGestureRecognizer(target: self, action: #selector(EditListingLocationViewController.action(_:)))
        tapToAddPin.minimumPressDuration = 0.20
        mapView.addGestureRecognizer(tapToAddPin)
    }
    
// MARK: - Custom Methods
    
    // Sets region for map view
    func setUpMapView(location: PFGeoPoint) {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
        self.mapView.setRegion(region, animated: false)
    }
    
    // When user presses map
    func action(gestureRecognizer:UIGestureRecognizer) {
        // Create a new annotation with the proper coordinates for the point pressed
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)

        // Remove previous pin from map
        mapView.removeAnnotation(newPin)
        // Set new coordinates
        newPin.coordinate = newCoordinate
        // Re-add pin to map
        mapView.addAnnotation(newPin)
    }
    
// MARK: - Mapview Delegate Methods
    
    // Returns a customized pin to display on the map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        pinView!.pinColor = .Purple
    
    return pinView
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        let newGeopoint = PFGeoPoint(latitude: newPin.coordinate.latitude, longitude: newPin.coordinate.longitude)
        delegate?.storePin(newGeopoint)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.transform = CGAffineTransformMakeScale(2, 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        listingObject["location"] = newGeopoint
        listingObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                activityView.stopAnimating()
                self.performSegueWithIdentifier("UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
}
