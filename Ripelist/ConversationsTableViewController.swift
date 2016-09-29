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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ConversationsTableViewController: PFQueryTableViewController {
    
// MARK: - Constants

    let theAskingViewForLogin = "AttemptToAccessSettings"
    
// MARK: - Variables

    var messager: PFUser!
    var messagers = [PFUser]()
    var postObject: PFObject!
    var postObjects = [PFObject]()
    var currentUser = PFUser.current()
    var postDeletedMessage: String?
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("All Conversations")
        stylePFLoadingViewTheHardWay()
        self.title = "Conversations"
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationsTableViewController.refresh), name: NSNotification.Name(rawValue: "updateParent"), object: nil)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if currentUser == nil {
            self.performSegue(withIdentifier: "UnwindToSettings", sender: self)
        } else {
            tableView.reloadData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateParent"), object: nil)
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
    
    func refresh() {
        self.loadObjects()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.parseClassName = "Room"
        self.pullToRefreshEnabled = true
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", currentUser!, currentUser!)
        let chatRooms = PFQuery(className: "Room", predicate: pred).includeKey("postId")
        chatRooms.order(byDescending: "createdAt")
        chatRooms.cachePolicy = .networkElseCache
        return chatRooms
    }
    
    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath?, object: PFObject!) -> PFTableViewCell? {
        let cell = tableView!.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath!) as! PFTableViewCell
        
        // Get the messager
        messager = object.object(forKey: "user2") as! PFUser
        if messager.objectId == currentUser!.objectId {
            messager = object.object(forKey: "user1") as! PFUser
        }
        
        if let post = object.object(forKey: "postId") as? PFObject {
            post.fetchIfNeededInBackground { (result, error) in
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
            (cell.viewWithTag(1) as! UILabel).textColor = UIColor.red
        }

        messagers.append(messager)
        messager.fetchIfNeededInBackground { (result, error) in
            let messagerName = result?["name"] as! NSString
            (cell.viewWithTag(2) as! UILabel).text = messagerName as String
        }
        return cell
    }

    
    // Remove current user from having unread messages
    func userHasViewedNewMessages(arrayOf: NSArray, cell: PFTableViewCell) {
        if arrayOf.contains(PFUser.current()!.objectId!) {
            cell.viewWithTag(3)?.layer.cornerRadius = 10
            cell.viewWithTag(3)?.clipsToBounds = true
            cell.viewWithTag(3)?.isHidden = false
        } else {
            cell.viewWithTag(3)?.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConversationVC") as! ConversationViewController
        
        let messager = messagers[(indexPath as NSIndexPath).row]
        
        var room = PFObject(className: "Room")
        let userPredicate = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", currentUser!, messager, messager, currentUser!)
        let roomQuery = PFQuery(className: "Room", predicate: userPredicate)
        
        let object = postObjects[(indexPath as NSIndexPath).row]
        if object["title"] == nil {
            conversationVC.postDeletedMessage = "This post has been deleted"
        } else {
            roomQuery.whereKey("postId", equalTo: postObjects[(indexPath as NSIndexPath).row])
            roomQuery.findObjectsInBackground(block: { (results, error) in
                if error == nil && results?.count > 0 {
                    room = results!.first as PFObject!
                    // Remove user from having unread notifications for this chat room
                    if let chattersWhoHaveUnreadMessages = room["hasUnreadMessages"] as? NSMutableArray {
                        if chattersWhoHaveUnreadMessages.contains(PFUser.current()!.objectId!) {
                            chattersWhoHaveUnreadMessages.remove(PFUser.current()!.objectId!)
                            room["hasUnreadMessages"] = chattersWhoHaveUnreadMessages
                            room.saveInBackground(block: nil)
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




