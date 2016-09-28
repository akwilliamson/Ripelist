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
        Apptentive.sharedConnection().engage("AppLaunched", from: self)
        self.logRegistrationEvents(forPossibleUser: PFUser.current(), atLocation: locationService.locationManager.location)
        
        locationService.locationManager.delegate = self
        locationService.startUpdatingLocation()
        
        self.registerCustomTableViewCellNibs()
        self.styleLoadingActivityIndicator(withinViews: self.view.subviews)
        self.configureSearchBar()
        self.addTarget(onControl: recentOrClosestSegmentedControl, forEvent: .valueChanged)
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
        tableView.register(UINib(nibName: "ListingCell", bundle: nil), forCellReuseIdentifier: "ListingCell")
        tableView.register(UINib(nibName: "RequestCell", bundle: nil), forCellReuseIdentifier: "RequestCell")
    }
    
    func addTarget(onControl control: UISegmentedControl, forEvent event: UIControlEvents) {
        control.addTarget(self, action: #selector(ListingsTableViewController.controlChanged(_:)), for: .valueChanged)
    }
    
    func styleLoadingActivityIndicator(withinViews views: [UIView]) {
        // go through all of the subviews until you find a PFLoadingView subclass
        views.forEach({ if NSStringFromClass($0.classForCoder) == "PFLoadingView" {
            // find the loading label and loading activity indicator inside the PFLoadingView subviews
            $0.subviews.forEach({ if $0 is UILabel { $0.isHidden = true } else if $0 is UIActivityIndicatorView {
                let indicatorView = $0 as! UIActivityIndicatorView
                indicatorView.activityIndicatorViewStyle = .white // Don't know how to hide so I made it white
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

    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Listing").includeKey("owner")
        query.cachePolicy = .networkElseCache
        
        if searchController.isActive {
            query.whereKey("title", matchesRegex: searchString, modifiers: "i")
            return query.order(byDescending: "updatedAt")
        } else {
            switch recentOrClosestSegmentedControl.selectedSegmentIndex {
            case 0: /* Most Recent */
                return query.order(byDescending: "updatedAt")
            case 1: /* Nearest */
                return query.whereKey("location", nearGeoPoint: PFGeoPoint(location: locationService.locationManager.location))
            default: /* Most Recent */
                return query.order(byDescending: "updatedAt")
            }
        }
    }
    
    func objectsDidLoad(_ error: NSError?) {
        super.objectsDidLoad(error)
        if error == nil {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        } else {
            print(error?.localizedDescription)
        }
    }
    
// MARK: Tableview Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject!) -> PFTableViewCell? {
        
        let localPost = LocalPost(postObject: object, postAuthor: (object.object(forKey: "owner") as! PFUser))
        
        if localPost.getPostType() == "listing" {
            let listingCell = tableView.dequeueReusableCell(withIdentifier: "ListingCell", for: indexPath) as! ListingCell
            let imageFile = object["image"] as? PFFile
            self.loadImage(inImageView: listingCell.listingImageView, withFile: imageFile)
            colorBarterLabels([listingCell.forSaleLabel, listingCell.forTradeLabel, listingCell.forFreeLabel],
                 barterTypes: [localPost.forSale(),      localPost.forTrade(),      localPost.forFree()])
            
            listingCell.setTitle(withText: localPost.getTitle())
            listingCell.setDistanceAway(fromPoint: locationService.locationManager.location, toPoint: localPost.getLocation())
            listingCell.setUsername(withText: localPost.getUsername())
            
            return listingCell
        } else {
            let requestCell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
            
            let swapType = object["swapType"] as? String
            requestCell.setSwapType(withText: swapType)
            requestCell.setTitle(withText: localPost.getTitle())
            requestCell.setDistanceAway(fromPoint: locationService.locationManager.location, toPoint: localPost.getLocation())
            requestCell.setUsername(withText: localPost.getUsername())
            
            return requestCell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
// MARK: Table View Data Source Helpers
    
    func loadImage(inImageView imageView: PFImageView, withFile imageFile: PFFile?) {
        imageView.image = UIImage(named: "placeholder.png")
        if let imageFile = imageFile {
            imageView.file = imageFile
            imageView.load(inBackground: nil)
        }
    }
    
    func colorBarterLabels(_ barterLabels: [UILabel], barterTypes: [Bool?]) {
        for (index, barterType) in barterTypes.enumerated() {
            guard let barterType = barterType else { return }
            barterLabels[index].backgroundColor = barterType == false ? UIColor.labelGreyColor() : UIColor.goldColor()
        }
    }

// MARK: - Tableview Delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .normal, title: "Share") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.logEvents("Share Action Swiped")
            guard let postObjectSwiped = self.objects?[(indexPath as NSIndexPath).row] else { return }
            let activityVC = self.createActivityVC(forPost: postObjectSwiped)
            self.present(activityVC, animated: true, completion: { _ in
                tableView.setEditing(false, animated: true)
            })
        }
        shareAction.backgroundColor = UIColor.goldColor()
        return [shareAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row > (objects?.count)! - 1 {
            loadNextPage()
            return
        }
        let segueString = tableView.cellForRow(at: indexPath) is ListingCell ? "ListingDetails" : "RequestDetails"
        self.performSegue(withIdentifier: segueString, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForNextPageAt indexPath: IndexPath) -> PFTableViewCell? {
        return NextPageCell()
    }
    
// MARK: - Actions
    
    @IBAction func menuTapped(_ sender: AnyObject) {
        self.logEvents("Slide Menu Tapped")
        let alert = Alert(title: "Slide Menu", message: "The ability to filter posts is coming next! Which filter do you prefer?")
        let feedback = PFObject(className: "Feedback")
        if let currentUser = PFUser.current() {
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
    
    func controlChanged(_ sender: UISegmentedControl) {
        self.loadObjects()
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
// MARK: - Transitions
    
    @IBAction func unwindToListingsTable(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Flurry.endTimedEvent("Main Listings", withParameters: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target:nil, action:nil)
        
        if segue.identifier == "RequestDetails" {
            guard let request = objects?[(tableView.indexPathForSelectedRow! as NSIndexPath).row] else { return }
            
            let requestDetailsVC = segue.destination as! RequestDetailsViewController
                requestDetailsVC.hidesBottomBarWhenPushed = true
                requestDetailsVC.localPost = LocalPost(postObject: request, postAuthor: (request["owner"] as! PFUser))
                searchController.isActive = false
            
        } else if segue.identifier == "ListingDetails" {
            guard let listing = objects?[(tableView.indexPathForSelectedRow! as NSIndexPath).row] else { return }
            
            let listingDetailsVC = segue.destination as! ListingDetailsViewController
                listingDetailsVC.hidesBottomBarWhenPushed = true
                listingDetailsVC.localPost = LocalPost(postObject: listing, postAuthor: (listing["owner"] as! PFUser))
                searchController.isActive = false
            
        } else if segue.identifier == "ShowMappedListings" {
            let mappedPostsVC = segue.destination as! MappedPostsViewController
                mappedPostsVC.mapLatitude = locationService.locationManager.location?.coordinate.latitude ?? 45.520591
                mappedPostsVC.mapLongitude = locationService.locationManager.location?.coordinate.longitude ?? -122.679298
        }
    }
}

// MARK: - Protocol: UISearchResultsUpdating

extension ListingsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchString = searchController.searchBar.text?.lowercased() ?? ""
        self.queryForTable()
        self.loadObjects()
    }
}

extension ListingsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

extension ListingsTableViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.loadObjects()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Update Location Error: \(error.localizedDescription)")
    }
}
