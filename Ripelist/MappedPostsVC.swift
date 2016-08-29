//
//  MappedListingsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 9/10/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit
import ParseUI
import Flurry_iOS_SDK

class MappedPostsViewController: UIViewController {

    let whiteColor = UIColor.whiteColor()
    
    var mapLatitude: Double?
    var mapLongitude: Double?
    var mappedPosts: NSArray?
    var locations: [MKPointAnnotation] = []
    var tappedPost: PFObject?
    var listingImageFile: PFFile?
    var tappedRegion: MKCoordinateRegion?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logStatusEvents()
        setTitleText()
        setRegionForMap()
        queryLocations()
    }
    
    func logStatusEvents() {
        let status = PFUser.currentUser() == nil ? "Not Registered" : "Registered"
        Flurry.logEvent("Main Listings Map View", withParameters: ["status": status], timed: true)
    }
    
    func setTitleText() {
        let titleFont = UIFont(name: "ArialRoundedMTBold", size: 25)!
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: whiteColor]
    }
    
    func setRegionForMap() {
        let center = CLLocationCoordinate2D(latitude: mapLatitude!, longitude: mapLongitude!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
        mapView.setRegion(region, animated: true)
    }
    
    func queryLocations() {
        let locationQuery = PFQuery(className: "Listing").includeKey("owner")
        locationQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            guard let fetchedPosts = results else { return }
            for post in fetchedPosts {
                let title = post["title"] as! String
                let imageFile = post["image"] as? PFFile
                let postLocation = (post["location"] as! PFGeoPoint)
                let coordinate = CLLocationCoordinate2D(latitude: postLocation.latitude, longitude: postLocation.longitude)
                let locationAnnotation = PostAnnotation(title: title, coordinate: coordinate, post: post, imageFile: imageFile)
                self.mapView.addAnnotation(locationAnnotation)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        Flurry.endTimedEvent("Main Listings Map View", withParameters: nil)
        if segue.identifier == "ListingDetails" {
            let listingDetailsVC = segue.destinationViewController as! ListingDetailsViewController
            listingDetailsVC.hidesBottomBarWhenPushed = true
            if let tappedPost = tappedPost {
                listingDetailsVC.localPost = LocalPost(postObject: tappedPost, postAuthor: (tappedPost["owner"] as! PFUser))
            }
        }
        if segue.identifier == "RequestDetails" {
            let requestDetailsVC = segue.destinationViewController as! RequestDetailsViewController
            requestDetailsVC.hidesBottomBarWhenPushed = true
            if let tappedPost = tappedPost {
                requestDetailsVC.localPost = LocalPost(postObject: tappedPost, postAuthor: (tappedPost["owner"] as! PFUser))
            }
        }
    }
}

extension MappedPostsViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.logEvents("Main View Map Pin Tapped")
        let annotation = view.annotation as! PostAnnotation
        self.tappedPost = annotation.post
        if let imageFile = annotation.imageFile {
            listingImageFile = imageFile
        }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        self.tappedRegion = MKCoordinateRegionMake(annotation.coordinate, span)
        
        let segueString = annotation.post["postType"] as! String == "listing" ? "ListingDetails" : "RequestDetails"
        self.performSegueWithIdentifier(segueString, sender: self)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let postPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PostPin")
        postPin.pinColor = .Purple
        postPin.canShowCallout = true
        postPin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return postPin
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = UIColor.purpleRadiusColor()
        return circle
    }
}
