//
//  ListingsTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/26/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import CoreLocation
import LKAlertController
import ParseUI
import Apptentive
import Flurry_iOS_SDK

class ListingsTableViewController: PFQueryTableViewController {
    
// MARK: - Properties
    
    let locationService = LocationService.sharedInstance
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor =  UIColor.forestColor()
        searchController.searchBar.sizeToFit()
        return searchController
    }()
    
    var searchString = ""
    
// MARK: - Outlets
    
    @IBOutlet weak var recentOrClosestSegmentedControl: UISegmentedControl!
    
// MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Apptentive.sharedConnection().engage("AppLaunched", fromViewController: self)
        self.logRegistrationEvents(forPossibleUser: PFUser.currentUser(), atLocation: locationService.locationManager.location)
        
        locationService.locationManager.delegate = self
        locationService.startUpdatingLocation()
        
        self.registerCustomTableViewCellNibs()
        self.styleLoadingActivityIndicator(withinViews: self.view.subviews)
        self.configureSearchBar()
        self.addTarget(onControl: recentOrClosestSegmentedControl, forEvent: .ValueChanged)
    }
    
// MARK: View Setup Helpers
    
    func logRegistrationEvents(forPossibleUser user: PFUser?, atLocation location: CLLocation?) {
        let registeredString = user != nil ? "Registered" : "Not Registered"
        self.logEvents("Main Listings", withParameters: ["status": registeredString], timed: true)
        guard let location = location else { return }
        Flurry.setLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude,
            horizontalAccuracy: Float(location.horizontalAccuracy),
            verticalAccuracy: Float(location.verticalAccuracy))
    }
    
    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    func registerCustomTableViewCellNibs() {
        tableView.registerNib(UINib(nibName: "ListingCell", bundle: nil), forCellReuseIdentifier: "ListingCell")
        tableView.registerNib(UINib(nibName: "RequestCell", bundle: nil), forCellReuseIdentifier: "RequestCell")
    }
    
    func addTarget(onControl control: UISegmentedControl, forEvent event: UIControlEvents) {
        control.addTarget(self, action: #selector(ListingsTableViewController.controlChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    func styleLoadingActivityIndicator(withinViews views: [UIView]) {
        // go through all of the subviews until you find a PFLoadingView subclass
        views.forEach({ if NSStringFromClass($0.classForCoder) == "PFLoadingView" {
            // find the loading label and loading activity indicator inside the PFLoadingView subviews
            $0.subviews.forEach({ if $0 is UILabel { $0.hidden = true } else if $0 is UIActivityIndicatorView {
                let indicatorView = $0 as! UIActivityIndicatorView
                indicatorView.activityIndicatorViewStyle = .White // Don't know how to hide so I made it white
                self.addCustomLoadingSubview(forView: indicatorView)
                }
            })
        }})
    }
    
    func addCustomLoadingSubview(forView view: UIActivityIndicatorView) {
        let indicator = LoadingIndicator()
        view.addSubview(indicator)
        indicator.startActivity()
    }
    
// MARK: - Parse Initialization

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Listing").includeKey("owner")
        query.cachePolicy = .NetworkElseCache
        
        if searchController.active {
            query.whereKey("title", matchesRegex: searchString, modifiers: "i")
            return query.orderByDescending("updatedAt")
        } else {
            switch recentOrClosestSegmentedControl.selectedSegmentIndex {
            case 0: /* Most Recent */
                return query.orderByDescending("updatedAt")
            case 1: /* Nearest */
                return query.whereKey("location", nearGeoPoint: PFGeoPoint(location: locationService.locationManager.location))
            default: /* Most Recent */
                return query.orderByDescending("updatedAt")
            }
        }
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        if error == nil {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        } else {
            print(error?.localizedDescription)
        }
    }
    
// MARK: Tableview Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        
        let localPost = LocalPost(postObject: object, postAuthor: (object.objectForKey("owner") as! PFUser))
        
        if localPost.getPostType() == "listing" {
            let listingCell = tableView.dequeueReusableCellWithIdentifier("ListingCell", forIndexPath: indexPath) as! ListingCell
            let imageFile = object["image"] as? PFFile
            self.loadImage(inImageView: listingCell.listingImageView, withFile: imageFile)
            colorBarterLabels([listingCell.forSaleLabel, listingCell.forTradeLabel, listingCell.forFreeLabel],
                 barterTypes: [localPost.forSale(),      localPost.forTrade(),      localPost.forFree()])
            
            listingCell.setTitle(withText: localPost.getTitle())
            listingCell.setDistanceAway(fromPoint: locationService.locationManager.location, toPoint: localPost.getLocation())
            listingCell.setUsername(withText: localPost.getUsername())
            
            return listingCell
        } else {
            let requestCell = tableView.dequeueReusableCellWithIdentifier("RequestCell", forIndexPath: indexPath) as! RequestCell
            
            let swapType = object["swapType"] as? String
            requestCell.setSwapType(withText: swapType)
            requestCell.setTitle(withText: localPost.getTitle())
            requestCell.setDistanceAway(fromPoint: locationService.locationManager.location, toPoint: localPost.getLocation())
            requestCell.setUsername(withText: localPost.getUsername())
            
            return requestCell
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
// MARK: Table View Data Source Helpers
    
    func loadImage(inImageView imageView: PFImageView, withFile imageFile: PFFile?) {
        imageView.image = UIImage(named: "placeholder.png")
        if let imageFile = imageFile {
            imageView.file = imageFile
            imageView.loadInBackground(nil)
        }
    }
    
    func colorBarterLabels(barterLabels: [UILabel], barterTypes: [Bool?]) {
        for (index, barterType) in barterTypes.enumerate() {
            guard let barterType = barterType else { return }
            barterLabels[index].backgroundColor = barterType == false ? UIColor.labelGreyColor() : UIColor.goldColor()
        }
    }

// MARK: - Tableview Delegate
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "Share") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            self.logEvents("Share Action Swiped")
            guard let postObjectSwiped = self.objects?[indexPath.row] else { return }
            let activityVC = self.createActivityVC(forPost: postObjectSwiped)
            self.presentViewController(activityVC, animated: true, completion: { _ in
                tableView.setEditing(false, animated: true)
            })
        }
        shareAction.backgroundColor = UIColor.goldColor()
        return [shareAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > (objects?.count)! - 1 {
            loadNextPage()
            return
        }
        let segueString = tableView.cellForRowAtIndexPath(indexPath) is ListingCell ? "ListingDetails" : "RequestDetails"
        self.performSegueWithIdentifier(segueString, sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        return NextPageCell()
    }
    
// MARK: - Actions
    
    @IBAction func menuTapped(sender: AnyObject) {
        self.logEvents("Slide Menu Tapped")
        let alert = Alert(title: "Slide Menu", message: "The ability to filter posts is coming next! Which filter do you prefer?")
        let feedback = PFObject(className: "Feedback")
        if let currentUser = PFUser.currentUser() {
            feedback["user"] = currentUser
        }
        alert.addAction("Filter between listings/requests", style: .Default) { action in
            feedback["slideMenu"] = "LR"
            feedback.saveInBackground()
            }.addAction("Filter by category", style: .Default) { action in
                feedback["slideMenu"] = "C"
                feedback.saveInBackground()
            }.addAction("Cancel", style: .Cancel, handler: nil)
            .show()
    }
    
    func controlChanged(sender: UISegmentedControl) {
        self.loadObjects()
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
// MARK: - Transitions
    
    @IBAction func unwindToListingsTable(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        Flurry.endTimedEvent("Main Listings", withParameters: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target:nil, action:nil)
        
        if segue.identifier == "RequestDetails" {
            guard let request = objects?[tableView.indexPathForSelectedRow!.row] else { return }
            
            let requestDetailsVC = segue.destinationViewController as! RequestDetailsViewController
                requestDetailsVC.hidesBottomBarWhenPushed = true
                requestDetailsVC.localPost = LocalPost(postObject: request, postAuthor: (request["owner"] as! PFUser))
                searchController.active = false
            
        } else if segue.identifier == "ListingDetails" {
            guard let listing = objects?[tableView.indexPathForSelectedRow!.row] else { return }
            
            let listingDetailsVC = segue.destinationViewController as! ListingDetailsViewController
                listingDetailsVC.hidesBottomBarWhenPushed = true
                listingDetailsVC.localPost = LocalPost(postObject: listing, postAuthor: (listing["owner"] as! PFUser))
                searchController.active = false
            
        } else if segue.identifier == "ShowMappedListings" {
            let mappedPostsVC = segue.destinationViewController as! MappedPostsViewController
                mappedPostsVC.mapLatitude = locationService.locationManager.location?.coordinate.latitude ?? 45.520591
                mappedPostsVC.mapLongitude = locationService.locationManager.location?.coordinate.longitude ?? -122.679298
        }
    }
}

// MARK: - Protocol: UISearchResultsUpdating

extension ListingsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchString = searchController.searchBar.text?.lowercaseString ?? ""
        self.queryForTable()
        self.loadObjects()
    }
}

extension ListingsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

extension ListingsTableViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.loadObjects()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Update Location Error: \(error.localizedDescription)")
    }
}
