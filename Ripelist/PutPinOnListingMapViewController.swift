//
//  PutPinOnMapViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/9/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import Flurry_iOS_SDK

class PutPinOnListingMapViewController: UIViewController,
                                        MKMapViewDelegate,
                                        CLLocationManagerDelegate {
    
// MARK: - Variables
    
    // Stores most recent pin placed on map
    var lastPin = [MKPointAnnotation()]
    // Informs whether pin should be shown or not on the map
    var shouldRemoveLastPin = false
    // Informs segue that it can be performed if pin has been placed
    var pinHasBeenPlaced = false
    // Stores address and zip in case the user cancels pin placement to prepopulate text fields in Create Listing B
    var address: String?
    var     zip: String?
    
// MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Add Location Pin For Listing")
        mapView.delegate = self
        
        // Setting the initial map's view and zoom levels
        let region = MapSetup.region
        mapView.setRegion(region, animated: true)
        
        // Add a gesture recognizer to the map that places an annotation where the user presses on the map
        let tapToAddPin = UILongPressGestureRecognizer(target: self, action: #selector(PutPinOnListingMapViewController.action(_:)))
        tapToAddPin.minimumPressDuration = 0.20
        mapView.addGestureRecognizer(tapToAddPin)
        
        // Passed from Create Listing B, if there was no address entered then keep and show the last location pin
        if shouldRemoveLastPin == false {
            mapView.addAnnotation(lastPin[0])
            pinHasBeenPlaced = true
        }
    }
        
// MARK: - Custom Methods
    
    // Action to take place when a user presses the map
    func action(_ gestureRecognizer:UIGestureRecognizer) {
        // Create a new annotation with the proper coordinates for the point pressed
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = newCoordinate
        
        // Remove previous pin from map and from the lastPin array
        mapView.removeAnnotation(lastPin[0])
        lastPin.remove(at: 0)
        
        // Add the new pin to the map and to the lastPin array
        mapView.addAnnotation(newAnnotation)
        lastPin.append(newAnnotation)
        
        // Let shouldPerformSegue that a pin has been placed and a user can select "Done"
        pinHasBeenPlaced = true
    }
    
// MARK: - Mapview Delegate Methods
    
    // Returns a customized pin to display on the map
    func mapView(_ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
// MARK: - Segue Methods
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        // Let user select "Done" if a pin has been placed on the map
        if identifier == "FinishPinOnMap" {
            // Don't perform the "Done" segue unless a pin has been placed
            if !pinHasBeenPlaced {
                let alert = UIAlertController(title: "No Pin", message: "Please add a pin before continuing", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return false
            } else {
                // If pin has been placed, allow "Done" segue
                return true
            }
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listingBController = segue.destination as! CreateListingBViewController
        if segue.identifier == "FinishPinOnMap" {
            // If segue is allowed, set Create Listing B's locationPin to the placed pin
            listingBController.locationPin = lastPin[0]
            // If Create Listing B's locationPin is set, set it's address and zip fields to blank
            if listingBController.locationPin != nil {
                listingBController.listingAddressField.text = ""
                listingBController.listingZipField.text = ""
            }
        }
    }
}
