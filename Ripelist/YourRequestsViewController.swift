//
//  YourRequestsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/31/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class YourRequestsViewController: PFQueryTableViewController {
    
// MARK: - Constants

    // Colors
    let greenColor = UIColor.forestColor()
    let goldColor = UIColor.goldColor()
    let greyColor = UIColor.labelGreyColor()
    
    var arrayOfRequestsInTable = [PFObject]()
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.parseClassName = "Listing"
        self.pullToRefreshEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Your Requests Main View")
        stylePFLoadingViewTheHardWay()
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey("owner", equalTo: PFObject(withoutDataWithClassName:"_User", objectId: PFUser.current()!.objectId))
        query.whereKey("postType", equalTo: "request")
        query.order(byDescending: "updatedAt")
        return query
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.current() == nil {
            self.performSegue(withIdentifier: "UnwindToPosts", sender: self)
        } else {
            self.loadObjects() 
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
                        label.isHidden = true
                    }
                    if loadingViewSubview is UIActivityIndicatorView {
                        let loadingSubview = loadingViewSubview as! UIActivityIndicatorView
                        loadingSubview.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white // Don't know how to hide so I made it white
                        
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
    
    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath?, object: PFObject!) -> PFTableViewCell? {
        arrayOfRequestsInTable.append(object)
        let requestCell = tableView!.dequeueReusableCell(withIdentifier: "YourRequestCell", for: indexPath!) as! PFTableViewCell
        
        let title = requestCell.viewWithTag(1) as! UILabel
        title.text = object["title"] as? String
        
        let swapTypeLabel = requestCell.viewWithTag(2) as! UILabel
        swapTypeLabel.layer.cornerRadius = 8
        swapTypeLabel.clipsToBounds = true
        let swapTypeString = object["swapType"] as? String
        swapTypeLabel.text = "  \(swapTypeString!)  "
        swapTypeLabel.backgroundColor = goldColor
        
        let descriptionLabel = requestCell.viewWithTag(3) as! UILabel
        let descriptionString = object["description"] as? String
        descriptionLabel.text = descriptionString
        
        let timeAgoLabel = requestCell.viewWithTag(4) as! UILabel
        timeAgoLabel.text = "posted: \(timeAgoSinceDate(object.updatedAt!, numericDates: true))"
        
//        let locationPoint = object["location"] as? PFGeoPoint
        
        return requestCell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            Flurry.logEvent("Delete Action Swiped")
            let request = self.arrayOfRequestsInTable[(indexPath as NSIndexPath).row] as PFObject
            let chatRoomQuery = PFQuery(className: "Room")
            chatRoomQuery.whereKey("postId", equalTo: PFObject(withoutDataWithClassName: "Listing", objectId: request.objectId))
            chatRoomQuery.findObjectsInBackground(block: { (chatRoomResults, error) in
                if chatRoomResults!.count > 0 {
                    let chatRooms = chatRoomResults as [PFObject]!
                    for chatRoom in chatRooms! {
                        let request = chatRoom["postId"] as! PFObject
                        
                        let messagesQuery = PFQuery(className: "Message")
                        messagesQuery.whereKey("room", equalTo: PFObject(withoutDataWithClassName: "Room", objectId: chatRoom.objectId))
                        messagesQuery.findObjectsInBackground(block: { (results, error) in
                            if results != nil {
                                let messages = results as [PFObject]!
                                for result in messages! {
                                    result.deleteInBackground(block: nil)
                                }
                            }
                        })
                        chatRoom.deleteInBackground(block: nil)
                        
                        self.removeObject(at: indexPath)
                        request.deleteInBackground(block: { (success, error) in
                            if success {
                                self.arrayOfRequestsInTable.removeAll(keepingCapacity: false)
                                self.loadObjects()
                            }
                        })
                    }
                } else {
                    let listing = self.object(at: indexPath)
                    self.removeObject(at: indexPath)
                    listing?.deleteInBackground(block: { (success, error) in
                        if success {
                            self.arrayOfRequestsInTable.removeAll(keepingCapacity: false)
                            self.loadObjects()
                        }
                    })
                }
            })

        }
        
        let refreshAction = UITableViewRowAction(style: .normal, title: "Refresh") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            Flurry.logEvent("Refresh Action Swiped")
            tableView.setEditing(false, animated: true)
            let request = self.arrayOfRequestsInTable[(indexPath as NSIndexPath).row] as PFObject
            request["updatedAt"] = Date()
            request.saveInBackground()
        }
        refreshAction.backgroundColor = UIColor.forestColor()
        
        let shareAction = UITableViewRowAction(style: .normal, title: "Share") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            Flurry.logEvent("Share Action Swiped")
            let request = self.arrayOfRequestsInTable[(indexPath as NSIndexPath).row] as PFObject
            let title = request["title"] as! String
            let string = "Someone is requesting: \(title) on Ripelist! Check out ripelist.com to learn more!"
            
            let activityViewController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor.goldColor()
        
        return [deleteAction, refreshAction, shareAction]
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
        let selectedRequest = arrayOfRequestsInTable[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        if segue.identifier == "ShowYourRequestDetails" {
            let yourRequestDetailsVC = segue.destination as! YourRequestDetailsViewController
            yourRequestDetailsVC.requestObject = selectedRequest
            yourRequestDetailsVC.requestSwapType = (selectedCell?.viewWithTag(2) as! UILabel).text
            yourRequestDetailsVC.timeAgoString = (selectedCell?.viewWithTag(4) as! UILabel).text
        }
    }
}
