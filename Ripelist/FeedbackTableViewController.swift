//
//  FeedbackTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 1/19/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import UIKit
import Apptentive

class FeedbackTableViewController: UITableViewController {
    
    let cellTitles = ["Give Feedback", "FAQ", "Rate Ripelist", "Privacy Policy"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.labelGreyColor()
    }

// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Feedback", forIndexPath: indexPath)
        cell.textLabel?.text = cellTitles[indexPath.row]
        cell.textLabel?.textColor = UIColor.forestColor()
        cell.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        cell.detailTextLabel?.text = "unread messages: \(Apptentive.sharedConnection().unreadMessageCount())"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Give Feedback" {
            Apptentive.sharedConnection().presentMessageCenterFromViewController(self)
        } else if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Rate Ripelist" {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/ripelist/id989376836?mt=8")!)
        } else if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Privacy Policy" {
            self.performSegueWithIdentifier("PrivacyPolicy", sender: self)
        } else if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "FAQ" {
            self.performSegueWithIdentifier("FAQ", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
