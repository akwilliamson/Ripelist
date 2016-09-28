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
        let backgroundView = UIView(frame: CGRect.zero)
        let borderLine =  UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.tableFooterView = backgroundView
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = borderLine
        tableView.tableFooterView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = greyColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold",
                                                                                               size: 25)!,
                                                        NSForegroundColorAttributeName: UIColor.white]
    }
    
    
// MARK: - Tableview Data Source Methods
    
    // Section for posting, section for posts
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Row for listings, row for requests
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // Cell in row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(requestIdentifiers[(indexPath as NSIndexPath).row])", for: indexPath)
            cell.textLabel!.text = requestOptions[(indexPath as NSIndexPath).row] as? String
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(listingIdentifiers[(indexPath as NSIndexPath).row])", for: indexPath)
            cell.textLabel!.text = listingOptions[(indexPath as NSIndexPath).row] as? String
            return cell
        }
    }
    
    // Section header title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Create Posts" : "My Posts"
    }
    
// MARK: - Tableview Delegate Methods
    
    // Section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    // Section header color
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.gray
        header.textLabel!.font = UIFont(name: "ArialRoundedMTBold", size: 18)
    }
    
    // Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    // If user is not logged in, perform onboard segue when cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if PFUser.current() == nil {
            selectedRow = (indexPath as NSIndexPath).row
            tableView.deselectRow(at: indexPath, animated: true)
            presentLogin()
        }
    }
    
    fileprivate func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewController(withIdentifier: "onboard_vc")
        present(OnboardVC, animated: true, completion: nil)
    }
    
// MARK: - Segue Methods
    
    @IBAction func unwindToAccessUserPostsAfterLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToPostsTable(_ segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return PFUser.current() == nil ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        if segue.identifier == "CreateListingA" {
            let createListingAController = segue.destination as! CreateListingAViewController
            createListingAController.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "CreateRequestA" {
            let createRequestAController = segue.destination as! CreateRequestAViewController
            createRequestAController.hidesBottomBarWhenPushed = true
        }
    }
}
