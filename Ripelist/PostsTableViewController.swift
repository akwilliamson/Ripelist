//
//  PostsTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/26/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class PostsTableViewController: UITableViewController {
    
// MARK: - Constants
    
    // Colors
    let greyColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    
    let theAskingViewForLogin = "AttemptToAccessPosts"
    
    let listingIdentifiers: NSArray = ["YourListingsCell", "YourRequestsCell"]
    let requestIdentifiers: NSArray = [ "AddListingsCell", "AddRequestCell"]
    
    let     listingOptions: NSArray = ["My Listings", "My Requests"]
    let     requestOptions: NSArray = ["Add Listing", "Add Request"]
    
// MARK: - Variables
    
    var selectedRow = 0

// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("My Posts Main View")
        let backgroundView = UIView(frame: CGRectZero)
        let borderLine =  UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 1))
        navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.tableFooterView = backgroundView
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.tableFooterView = borderLine
        tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor = greyColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold",
                                                                                               size: 25)!,
                                                        NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    
// MARK: - Tableview Data Source Methods
    
    // Section for posting, section for posts
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // Row for listings, row for requests
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // Cell in row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("\(requestIdentifiers[indexPath.row])", forIndexPath: indexPath)
            cell.textLabel!.text = requestOptions[indexPath.row] as? String
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("\(listingIdentifiers[indexPath.row])", forIndexPath: indexPath)
            cell.textLabel!.text = listingOptions[indexPath.row] as? String
            return cell
        }
    }
    
    // Section header title
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Create Posts" : "My Posts"
    }
    
// MARK: - Tableview Delegate Methods
    
    // Section header height
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    // Section header color
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.grayColor()
        header.textLabel!.font = UIFont(name: "ArialRoundedMTBold", size: 18)
    }
    
    // Row height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // If user is not logged in, perform onboard segue when cell is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            selectedRow = indexPath.row
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            presentLogin()
        }
    }
    
    private func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewControllerWithIdentifier("onboard_vc")
        presentViewController(OnboardVC, animated: true, completion: nil)
    }
    
// MARK: - Segue Methods
    
    @IBAction func unwindToAccessUserPostsAfterLogin(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToPostsTable(segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return PFUser.currentUser() == nil ? false : true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        if segue.identifier == "CreateListingA" {
            let createListingAController = segue.destinationViewController as! CreateListingAViewController
            createListingAController.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "CreateRequestA" {
            let createRequestAController = segue.destinationViewController as! CreateRequestAViewController
            createRequestAController.hidesBottomBarWhenPushed = true
        }
    }
}
