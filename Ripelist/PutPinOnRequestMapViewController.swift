//
//  PutPinOnRequestMapViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/25/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import Flurry_iOS_SDK

class PutPinOnRequestMapViewController: UIViewController,
                                        MKMapViewDelegate,
                                        CLLocationManagerDelegate {
    
// MARK: - Variables
    
    var lastPin = [MKPointAnnotation()]
    var shouldRemoveLastPin = false
    var pinHasBeenPlaced = false
    // Stores address and zip, in case the user cancels, to prepopulate text fields in Create Request B
    var address: String?
    var zip: String?
    
// MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - View Construction 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Add Location Pin For Request")
        mapView.delegate = self
        
        // Setting the initial map's view and zoom levels
        let region = MapSetup.region
        mapView.setRegion(region, animated: true)
        
        // Add a gesture recognizer to the map that places an annotation where the user presses on the map
        let tapToAddPin = UILongPressGestureRecognizer(target: self, action: #selector(PutPinOnRequestMapViewController.action(_:)))
        tapToAddPin.minimumPressDuration = 0.20
        mapView.addGestureRecognizer(tapToAddPin)
        
        // Passed from Create Request B, if there was no address entered then keep and show the last location pin
        if shouldRemoveLastPin == false {
            mapView.addAnnotation(lastPin[0])
            pinHasBeenPlaced = true
        }
    }
    
    // Returns a customized pin to display on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView!.canShowCallout = true
            } else {
                pinView!.annotation = annotation
            }
            pinView!.pinColor = .purple
            
            return pinView
    }
    
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
        let requestBController = segue.destination as! CreateRequestBViewController
        if segue.identifier == "FinishPinOnMap" {
            // If segue is allowed, set Create Request B's locationPin to the placed pin
            requestBController.locationPin = lastPin[0]
            // If Create Request B's locationPin is set, set it's address and zip fields to blank
            if requestBController.locationPin != nil {
                requestBController.requestAddressField.text = ""
                requestBController.requestZipField.text = ""
            }
        }
    }
}
