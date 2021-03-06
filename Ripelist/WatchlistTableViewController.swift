//
//  WatchlistTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 8/13/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class WatchlistTableViewController: PFQueryTableViewController {

    let locationManager = CLLocationManager()
    var currentLocationPoint = CLLocation()
    // Holds queried Post objects
    var arrayOfListingsInTable = [PFObject]()
    
// MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Watchlist Table View")
        stylePFLoadingViewTheHardWay()
        setTitleText()
        startLocationManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        checkIfUserIsLoggedIn()
    }
    
// MARK: - View Setup Helper Methods
    
    func setTitleText() {
        self.title = "Watchlist"
    }
    
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func checkIfUserIsLoggedIn() {
        if PFUser.currentUser() == nil {
            self.performSegueWithIdentifier("UnwindToPosts", sender: AnyObject?())
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.parseClassName = "Watchlist"
        self.pullToRefreshEnabled = true
    }
    
    // All watchlist items for current user
    override func queryForTable() -> PFQuery {
        let watchlistQuery = PFQuery(className: "Watchlist")
            watchlistQuery.whereKey("user", equalTo: PFUser.currentUser()!)
            watchlistQuery.includeKey("user")
            watchlistQuery.includeKey("post")
            watchlistQuery.orderByDescending("updatedAt")
        return watchlistQuery
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        if error != nil {
            print(error?.localizedDescription)
        }
    }
    
    func stylePFLoadingViewTheHardWay() {
        // go through all of the subviews until you find a PFLoadingView subclass
        for view in self.view.subviews {
            if NSStringFromClass(view.classForCoder) == "PFLoadingView" {
                // find the loading label and loading activity indicator inside the PFLoadingView subviews
                for loadingViewSubview in view.subviews {
                    if loadingViewSubview is UILabel {
                        let label = loadingViewSubview as! UILabel
                        label.hidden = true
                    }
                    if loadingViewSubview is UIActivityIndicatorView {
                        let loadingSubview = loadingViewSubview as! UIActivityIndicatorView
                        loadingSubview.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White // Don't know how to hide so I made it white
                        
                        let indicator = DTIActivityIndicatorView(frame: CGRect(x:0.0, y:0.0, width:80.0, height:80.0))
                        indicator.indicatorColor = UIColor.forestColor()
                        indicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
                        loadingViewSubview.addSubview(indicator)
                        indicator.startActivity()
                    }
                }
                
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        // Append to array if neccessary
        if object["post"] == nil {
            object.deleteInBackground()
        } else {
            if !arrayOfListingsInTable.contains(object["post"] as! PFObject) {
                arrayOfListingsInTable.append(object["post"] as! PFObject)
            }
        }
        // Dequeue cell
        let listingCell = tableView.dequeueReusableCellWithIdentifier("ListingCell", forIndexPath: indexPath) as! PFTableViewCell
        // Access labels
        let    photoLabel = listingCell.viewWithTag(1) as! PFImageView
        let    titleLabel = listingCell.viewWithTag(2) as! UILabel
        let  forSaleLabel = listingCell.viewWithTag(3) as! UILabel
        let forTradeLabel = listingCell.viewWithTag(4) as! UILabel
        let  forFreeLabel = listingCell.viewWithTag(5) as! UILabel
        _ = listingCell.viewWithTag(6) as! UILabel
        let  timeAgoLabel = listingCell.viewWithTag(7) as! UILabel
        let usernameLabel = listingCell.viewWithTag(8) as! UILabel
        // Access parameters
        let    listing = object["post"]        as! PFObject
        let       user = listing["owner"]      as? PFUser
        let  createdAt = listing["createdAt"]  as? NSDate
        let      title = listing["title"]      as? String
        let      price = listing["price"]      as? String
        let   forTrade = listing["forTrade"]   as? Bool
        let   forFree  = listing["forFree"]    as? Bool
        let      image = listing["image"]      as? PFFile
        let   location = listing["location"]   as? PFGeoPoint
        
        // Set image
        loadImage(photoLabel, imageFile: image)
        
        // Set title
        if let title = title {
            titleLabel.text = title
        }
        
        // Custom logic
        var isForSale = false
        if price != "" && price != "0.00" {
            isForSale = true
        }
        
        setBarterLabels([forSaleLabel, forTradeLabel, forFreeLabel], barterTypes: [isForSale, forTrade, forFree])
        
        // Distance away label
        if locationManager.location != nil {
            if let _ = location {
                // Needs to be reimplemented with custom nib cell
//                location.setDistanceFromLabel(distanceLabel, postLocationPoint: location, currentLocationPoint: currentLocationPoint)
            }
        }
        
        // Set time ago
        if let createdAt = createdAt {
            timeAgoLabel.text = "posted " + createdAt.timeAgoSinceDate()
        }
        
        // Set username
        if let user = user {
            user.fetchIfNeededInBackgroundWithBlock({ (result: PFObject?, error: NSError?) -> Void in
                if let username = result!["name"] as? String {
                    usernameLabel.text = "By: " + username
                }
            })
        }
        return listingCell
    }
    
    // Custom Methods
    
    func loadImage(imageView: PFImageView, imageFile: PFFile?) {
        imageView.image = UIImage(named: "placeholder.png")
        imageView.file = imageFile
        imageView.loadInBackground(nil)
    }
    
    func setBarterLabels(labels: [UILabel], barterTypes: [Bool?]) {
        for (index, barterType) in barterTypes.enumerate() {
            let barterLabel = labels[index]
            barterLabel.layer.cornerRadius = 8
            barterLabel.clipsToBounds = true
            if let barterType = barterType {
                if barterType == false {
                    barterLabel.backgroundColor = UIColor.labelGreyColor()
                } else {
                    barterLabel.backgroundColor = UIColor.goldColor()
                }
            }
        }
    }
    
    // MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        if segue.identifier == "ListingDetails" {
            let listing = arrayOfListingsInTable[tableView.indexPathForSelectedRow!.row]
            let listingDetailsVC = segue.destinationViewController as! ListingDetailsViewController
                listingDetailsVC.hidesBottomBarWhenPushed = true
                listingDetailsVC.localPost = LocalPost(postObject: listing, postAuthor: (listing["owner"] as! PFUser))
                listingDetailsVC.displayedFromWatchlist = true
        }
    }
}

extension WatchlistTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationPoint = locations.last as CLLocation!
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager:didFailWithError: ", error.localizedDescription)
    }
}

