//
//  SettingsTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/26/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import QuartzCore
import ParseUI
import Flurry_iOS_SDK

class SettingsTableViewController: UITableViewController {
    
// MARK: - Constants
    
    let greyColor = UIColor.labelGreyColor()
    // Reference passed to onboard view controller to unwind to proper view
    let theAskingViewForLogin = "AttemptToAccessSettings"
    
// MARK: - Variables
    
    //
    var settingsCells = ["ConversationsCell", "Location", "Watchlist", "LogoutCell"]
    var isTheUserLoggedIn = false
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Settings Main View")
        let backgroundView = UIView(frame: CGRectZero)
        let borderLine =  UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 1))
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.tableFooterView = borderLine
        self.tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = greyColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold",
                                                                                                    size: 25)!,
                                                                        NSForegroundColorAttributeName: UIColor.whiteColor()]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.refresh), name: "updateParent", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Set badge value on tab to proper number when view appears
        let currentTabBarItem = self.tabBarController!.tabBar.items![2] as UITabBarItem
        
        if PFInstallation.currentInstallation()?.badge != 0 {
            tableView.reloadData()
            currentTabBarItem.badgeValue = String(PFInstallation.currentInstallation()?.badge)
        } else {
            currentTabBarItem.badgeValue = nil
        }
    }
    
    func refresh() {
        tableView.reloadData()
    }
    
    // Add "logout" cell if user is logged in, otherwise don't
    override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            isTheUserLoggedIn = true
            if !settingsCells.contains("LogoutCell") {
                settingsCells.insert("LogoutCell", atIndex: settingsCells.count)
                tableView.reloadData()
            }
        } else {
            isTheUserLoggedIn = false
            if settingsCells.count == 4 {
                settingsCells.removeLast()
            }
            tableView.reloadData()
        }
    }
    
// MARK: - Tableview Data Source Methods
    
    // Sections in table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Rows in section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsCells.count
    }
    
    // Cell in row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(settingsCells[indexPath.row], forIndexPath: indexPath)
        if PFInstallation.currentInstallation()?.badge != 0 {
            cell.viewWithTag(1)?.layer.cornerRadius = 10
            cell.viewWithTag(1)?.clipsToBounds = true
            cell.viewWithTag(1)?.hidden = false
        } else {
            cell.viewWithTag(1)?.hidden = true
        }
        
        return cell
    }
    
// MARK: - Tableview Delegate Methods
    
    // Row height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    private func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewControllerWithIdentifier("onboard_vc")
        presentViewController(OnboardVC, animated: true, completion: nil)
    }
    
    // Segue to onboard view or a logout conformation depending on whether user is logged in or not
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if !isTheUserLoggedIn {
            presentLogin()
        } else if settingsCells[indexPath.row] == "LogoutCell" {
            let alert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: { action in
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
            let confirmAction = UIAlertAction(title: "Yes", style: .Default, handler: { action in
                let userInstallation = PFInstallation.currentInstallation()
                userInstallation?.removeObjectForKey("user")
                userInstallation?.saveInBackgroundWithBlock(nil)

                PFUser.logOut()
                self.isTheUserLoggedIn = false
                self.settingsCells.removeLast()
                tableView.reloadData()
            })
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if indexPath.row == 0 {
            PFInstallation.currentInstallation()?.badge = 0
            PFInstallation.currentInstallation()?.saveInBackground()
        } else if settingsCells[indexPath.row] == "Watchlist" {
        }
    }
    
// MARK: - Segue Methods
    
    @IBAction func unwindToSettingsAfterLogin(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return PFUser.currentUser() == nil ? false : true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        if segue.identifier == "ShowLocationPreferences" {
            let showLocationPreferencesVC = segue.destinationViewController as! LocationSettingsViewController
            showLocationPreferencesVC.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "ShowConversations" {
            let showConversationsVC = segue.destinationViewController as! ConversationsTableViewController
            showConversationsVC.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "ShowWatchlist" {
            let showWatchlistVC = segue.destinationViewController as! WatchlistTableViewController
            showWatchlistVC.hidesBottomBarWhenPushed = true
        }
    }
}





