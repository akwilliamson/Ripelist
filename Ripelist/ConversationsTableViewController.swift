//
//  ConversationsTableViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/10/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import QuartzCore
import ParseUI
import Flurry_iOS_SDK

class ConversationsTableViewController: PFQueryTableViewController {
    
// MARK: - Constants

    let theAskingViewForLogin = "AttemptToAccessSettings"
    
// MARK: - Variables

    var messager: PFUser!
    var messagers = [PFUser]()
    var postObject: PFObject!
    var postObjects = [PFObject]()
    var currentUser = PFUser.currentUser()
    var postDeletedMessage: String?
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("All Conversations")
        stylePFLoadingViewTheHardWay()
        self.title = "Conversations"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationsTableViewController.refresh), name: "updateParent", object: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if currentUser == nil {
            self.performSegueWithIdentifier("UnwindToSettings", sender: AnyObject?())
        } else {
            tableView.reloadData()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateParent", object: nil)
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
    
    func refresh() {
        self.loadObjects()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.parseClassName = "Room"
        self.pullToRefreshEnabled = true
    }
    
    override func queryForTable() -> PFQuery {
        let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", currentUser!, currentUser!)
        let chatRooms = PFQuery(className: "Room", predicate: pred).includeKey("postId")
        chatRooms.orderByDescending("createdAt")
        chatRooms.cachePolicy = .NetworkElseCache
        return chatRooms
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?, object: PFObject!) -> PFTableViewCell? {
        let cell = tableView!.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath!) as! PFTableViewCell
        
        // Get the messager
        messager = object.objectForKey("user2") as! PFUser
        if messager.objectId == currentUser!.objectId {
            messager = object.objectForKey("user1") as! PFUser
        }
        
        if let post = object.objectForKey("postId") as? PFObject {
            post.fetchIfNeededInBackgroundWithBlock { (result: PFObject?, error: NSError?) -> Void in
                self.postObjects.append(post)
                let postTitle = result?["title"] as! String
                if let chattersWhoHaveUnreadMessages = object["hasUnreadMessages"] as? NSArray {
                    self.userHasViewedNewMessages(arrayOf: chattersWhoHaveUnreadMessages, cell: cell)
                }
                (cell.viewWithTag(1) as! UILabel).text = postTitle as String
            }
        } else {
            let emptyObject = PFObject()
            postObjects.append(emptyObject)
            (cell.viewWithTag(1) as! UILabel).text = "Deleted"
            (cell.viewWithTag(1) as! UILabel).textColor = UIColor.redColor()
        }

        messagers.append(messager)
        messager.fetchIfNeededInBackgroundWithBlock { (result: PFObject?, error: NSError?) -> Void in
            let messagerName = result?["name"] as! NSString
            (cell.viewWithTag(2) as! UILabel).text = messagerName as String
        }
        return cell
    }

    
    // Remove current user from having unread messages
    func userHasViewedNewMessages(arrayOf arrayOf: NSArray, cell: PFTableViewCell) {
        if arrayOf.containsObject(PFUser.currentUser()!.objectId!) {
            cell.viewWithTag(3)?.layer.cornerRadius = 10
            cell.viewWithTag(3)?.clipsToBounds = true
            cell.viewWithTag(3)?.hidden = false
        } else {
            cell.viewWithTag(3)?.hidden = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let conversationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ConversationVC") as! ConversationViewController
        
        let messager = messagers[indexPath.row]
        
        var room = PFObject(className: "Room")
        let userPredicate = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", currentUser!, messager, messager, currentUser!)
        let roomQuery = PFQuery(className: "Room", predicate: userPredicate)
        
        let object = postObjects[indexPath.row]
        if object["title"] == nil {
            conversationVC.postDeletedMessage = "This post has been deleted"
        } else {
            roomQuery.whereKey("postId", equalTo: postObjects[indexPath.row])
            roomQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil && results?.count > 0 {
                    room = results!.first as PFObject!
                    // Remove user from having unread notifications for this chat room
                    if let chattersWhoHaveUnreadMessages = room["hasUnreadMessages"] as? NSMutableArray {
                        if chattersWhoHaveUnreadMessages.containsObject(PFUser.currentUser()!.objectId!) {
                            chattersWhoHaveUnreadMessages.removeObject(PFUser.currentUser()!.objectId!)
                            room["hasUnreadMessages"] = chattersWhoHaveUnreadMessages
                            room.saveInBackgroundWithBlock(nil)
                        }
                    }
                    conversationVC.room = room
                    conversationVC.incomingUser = messager
                    conversationVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(conversationVC, animated: true)
                }
            })
        }
    }
}




