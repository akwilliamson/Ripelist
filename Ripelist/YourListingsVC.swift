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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.current() == nil {
            self.performSegue(withIdentifier: "UnwindToPosts", sender: AnyObject?())
        }
    }
    
// MARK: - View Setup Helpers
    
    func registerCustomCellNibs() {
        let listingCellNib = UINib(nibName: "ListingCell", bundle: nil)
        tableView.register(listingCellNib, forCellReuseIdentifier: "ListingCell")
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
        let query = PFQuery(className: "Listing")
        query.whereKey("owner", equalTo: PFObject(withoutDataWithClassName:"_User", objectId: PFUser.current()!.objectId))
        query.whereKey("postType", equalTo: "listing")
        query.order(byDescending: "updatedAt")
        
        return query
    }
    
// MARK: Tableview Data Source

    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath?, object: PFObject!) -> PFTableViewCell? {
        
        let localPost = LocalPost(postObject: object, postAuthor: (object.object(forKey: "owner") as! PFUser))
        
        let listingCell = tableView!.dequeueReusableCell(withIdentifier: "ListingCell", for: indexPath!) as! ListingCell
        
        let imageFile = object["image"] as? PFFile
        self.loadImage(inImageView: listingCell.listingImageView, withFile: imageFile)
        colorBarterLabels([listingCell.forSaleLabel, listingCell.forTradeLabel, listingCell.forFreeLabel],
            barterTypes: [localPost.forSale(),      localPost.forTrade(),      localPost.forFree()])
        
        listingCell.setTitle(withText: localPost.getTitle())
//        listingCell.setTimeAgo(atTime: object.updatedAt)
        
        return listingCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ListingDetails", sender: self)
    }
    
// MARK: Tableview Data Source Helpers
    
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
    
// MARK: - Transitions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourListingDetailsVC = segue.destination as! YourListingDetailsViewController
        
        guard let listing = objects?[(tableView.indexPathForSelectedRow! as NSIndexPath).row] else { return }
        yourListingDetailsVC.localPost = LocalPost(postObject: listing, postAuthor: (listing["owner"] as! PFUser))
    }
}
