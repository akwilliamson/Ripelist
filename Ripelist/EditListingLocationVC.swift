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
            NSForegroundColorAttributeName: UIColor.white]
        
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
    func setUpMapView(_ location: PFGeoPoint) {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
        self.mapView.setRegion(region, animated: false)
    }
    
    // When user presses map
    func action(_ gestureRecognizer:UIGestureRecognizer) {
        // Create a new annotation with the proper coordinates for the point pressed
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)

        // Remove previous pin from map
        mapView.removeAnnotation(newPin)
        // Set new coordinates
        newPin.coordinate = newCoordinate
        // Re-add pin to map
        mapView.addAnnotation(newPin)
    }
    
// MARK: - Mapview Delegate Methods
    
    // Returns a customized pin to display on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        pinView!.pinColor = .purple
    
    return pinView
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        let newGeopoint = PFGeoPoint(latitude: newPin.coordinate.latitude, longitude: newPin.coordinate.longitude)
        delegate?.storePin(newGeopoint)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        listingObject["location"] = newGeopoint
        listingObject.saveInBackground { (success, error) in
            if success {
                activityView.stopAnimating()
                self.performSegue(withIdentifier: "UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
}
