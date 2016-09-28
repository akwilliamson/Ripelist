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
        let backgroundView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.labelGreyColor()
    }

// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Feedback", for: indexPath)
        cell.textLabel?.text = cellTitles[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor.forestColor()
        cell.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        cell.detailTextLabel?.text = "unread messages: \(Apptentive.sharedConnection().unreadMessageCount)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Give Feedback" {
            Apptentive.sharedConnection().presentMessageCenter(from: self)
        } else if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Rate Ripelist" {
            UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/ripelist/id989376836?mt=8")!)
        } else if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Privacy Policy" {
            self.performSegue(withIdentifier: "PrivacyPolicy", sender: self)
        } else if tableView.cellForRow(at: indexPath)?.textLabel?.text == "FAQ" {
            self.performSegue(withIdentifier: "FAQ", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
