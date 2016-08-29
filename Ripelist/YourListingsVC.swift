//
//  YourListingsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/31/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI

class YourListingsViewController: PFQueryTableViewController {
    
// MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvents("Your Listings Main View")
        registerCustomCellNibs()
        styleLoadingActivityIndicator(withinViews: self.view.subviews)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.currentUser() == nil {
            self.performSegueWithIdentifier("UnwindToPosts", sender: AnyObject?())
        }
    }
    
// MARK: - View Setup Helpers
    
    func registerCustomCellNibs() {
        let listingCellNib = UINib(nibName: "ListingCell", bundle: nil)
        tableView.registerNib(listingCellNib, forCellReuseIdentifier: "ListingCell")
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
        let query = PFQuery(className: "Listing")
        query.whereKey("owner", equalTo: PFObject(withoutDataWithClassName:"_User", objectId: PFUser.currentUser()!.objectId))
        query.whereKey("postType", equalTo: "listing")
        query.orderByDescending("updatedAt")
        
        return query
    }
    
// MARK: Tableview Data Source

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?, object: PFObject!) -> PFTableViewCell? {
        
        let localPost = LocalPost(postObject: object, postAuthor: (object.objectForKey("owner") as! PFUser))
        
        let listingCell = tableView!.dequeueReusableCellWithIdentifier("ListingCell", forIndexPath: indexPath!) as! ListingCell
        
        let imageFile = object["image"] as? PFFile
        self.loadImage(inImageView: listingCell.listingImageView, withFile: imageFile)
        colorBarterLabels([listingCell.forSaleLabel, listingCell.forTradeLabel, listingCell.forFreeLabel],
            barterTypes: [localPost.forSale(),      localPost.forTrade(),      localPost.forFree()])
        
        listingCell.setTitle(withText: localPost.getTitle())
//        listingCell.setTimeAgo(atTime: object.updatedAt)
        
        return listingCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ListingDetails", sender: self)
    }
    
// MARK: Tableview Data Source Helpers
    
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
    
// MARK: - Transitions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let yourListingDetailsVC = segue.destinationViewController as! YourListingDetailsViewController
        
        guard let listing = objects?[tableView.indexPathForSelectedRow!.row] else { return }
        yourListingDetailsVC.localPost = LocalPost(postObject: listing, postAuthor: (listing["owner"] as! PFUser))
    }
}
