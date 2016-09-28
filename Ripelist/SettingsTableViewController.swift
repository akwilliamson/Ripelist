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
        let backgroundView = UIView(frame: CGRect.zero)
        let borderLine =  UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.white
        self.tableView.tableFooterView = borderLine
        self.tableView.tableFooterView?.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = greyColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold",
                                                                                                    size: 25)!,
                                                                        NSForegroundColorAttributeName: UIColor.white]
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.refresh), name: NSNotification.Name(rawValue: "updateParent"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set badge value on tab to proper number when view appears
        let currentTabBarItem = self.tabBarController!.tabBar.items![2] as UITabBarItem
        
        if PFInstallation.current()?.badge != 0 {
            tableView.reloadData()
            currentTabBarItem.badgeValue = String(describing: PFInstallation.current()?.badge)
        } else {
            currentTabBarItem.badgeValue = nil
        }
    }
    
    func refresh() {
        tableView.reloadData()
    }
    
    // Add "logout" cell if user is logged in, otherwise don't
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            isTheUserLoggedIn = true
            if !settingsCells.contains("LogoutCell") {
                settingsCells.insert("LogoutCell", at: settingsCells.count)
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsCells.count
    }
    
    // Cell in row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCells[(indexPath as NSIndexPath).row], for: indexPath)
        if PFInstallation.current()?.badge != 0 {
            cell.viewWithTag(1)?.layer.cornerRadius = 10
            cell.viewWithTag(1)?.clipsToBounds = true
            cell.viewWithTag(1)?.isHidden = false
        } else {
            cell.viewWithTag(1)?.isHidden = true
        }
        
        return cell
    }
    
// MARK: - Tableview Delegate Methods
    
    // Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    fileprivate func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewController(withIdentifier: "onboard_vc")
        present(OnboardVC, animated: true, completion: nil)
    }
    
    // Segue to onboard view or a logout conformation depending on whether user is logged in or not
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isTheUserLoggedIn {
            presentLogin()
        } else if settingsCells[(indexPath as NSIndexPath).row] == "LogoutCell" {
            let alert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let userInstallation = PFInstallation.current()
                userInstallation?.remove(forKey: "user")
                userInstallation?.saveInBackground(block: nil)

                PFUser.logOut()
                self.isTheUserLoggedIn = false
                self.settingsCells.removeLast()
                tableView.reloadData()
            })
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        } else if (indexPath as NSIndexPath).row == 0 {
            PFInstallation.current()?.badge = 0
            PFInstallation.current()?.saveInBackground()
        } else if settingsCells[(indexPath as NSIndexPath).row] == "Watchlist" {
        }
    }
    
// MARK: - Segue Methods
    
    @IBAction func unwindToSettingsAfterLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToSettings(_ segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return PFUser.current() == nil ? false : true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        if segue.identifier == "ShowLocationPreferences" {
            let showLocationPreferencesVC = segue.destination as! LocationSettingsViewController
            showLocationPreferencesVC.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "ShowConversations" {
            let showConversationsVC = segue.destination as! ConversationsTableViewController
            showConversationsVC.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "ShowWatchlist" {
            let showWatchlistVC = segue.destination as! WatchlistTableViewController
            showWatchlistVC.hidesBottomBarWhenPushed = true
        }
    }
}





