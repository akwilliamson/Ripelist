//
//  ContactRequesterViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/8/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ParseUI
import Flurry_iOS_SDK

class ConversationViewController: JSQMessagesViewController {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    let goldColor = UIColor.goldColor()
    
// MARK: - Variables

    var postDeletedMessage: String?
    var room: PFObject!
    var incomingUser: PFUser!
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var messageObjects = [PFObject]()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var selfAvatar: JSQMessagesAvatarImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    
// MARK: - View Construction
    
    @IBOutlet weak var deletedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Conversation Details")
        if postDeletedMessage == nil {
            
            deletedLabel.hidden = true
            
            inputToolbar!.contentView!.leftBarButtonItem = nil
            
            title = "Messages"
            senderId = PFUser.currentUser()!.objectId
            senderDisplayName = PFUser.currentUser()!.username
            
            let selfUsername = PFUser.currentUser()!.objectForKey("name") as! NSString
            incomingUser.fetchIfNeededInBackgroundWithBlock { (result: PFObject?, error: NSError?) -> Void in
            let incomingUsername = result?.objectForKey("name") as! NSString
                
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(incomingUsername.substringWithRange(NSMakeRange(0, 1)), backgroundColor: self.greenColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
            
            selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(selfUsername.substringWithRange(NSMakeRange(0, 1)), backgroundColor: goldColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(goldColor)
            incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(greenColor)
        } else {
            deletedLabel.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if postDeletedMessage == nil {
            loadMessages()
        }
    }
    
    // Load Messages
    func loadMessages() {
        var lastMessage: JSQMessage? = nil
        
        if messages.last != nil {
            lastMessage = messages.last
        }
        
        let messageQuery = PFQuery(className: "Message")
        messageQuery.whereKey("room", equalTo: room)
        messageQuery.orderByAscending("createdAt")
        messageQuery.limit = 20
        messageQuery.includeKey("user")
        
        if lastMessage != nil {
            messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date)
        }
        
        messageQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let messages = results as [PFObject]!
                for message in messages {
                    self.messageObjects.append(message)
                    
                    let user = message["user"] as! PFUser
                    self.users.append(user)
                    
                    let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["content"] as! String)
                    self.messages.append(chatMessage)
                }
                
                if results!.count != 0 {
                    self.finishReceivingMessage()
                }
            }
        }
    }
    
    // Send Messages
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = PFObject(className: "Message")
        message["content"] = text
        message["room"] = room
        message["user"] = PFUser.currentUser()
        
        message.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if error == nil {
                self.loadMessages()
                self.room["lastUpdate"] = NSDate()
                self.room.addObject(self.incomingUser.objectId!, forKey: "hasUnreadMessages")
                self.room.saveInBackgroundWithBlock(nil)
            } else {
                print("error sending message: \(error!.localizedDescription)")
            }
        }
        self.finishSendingMessage()
        
        // Send push notification to message receiver
       let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: incomingUser)
        
        let push = PFPush()
        push.setQuery(pushQuery)
        let senderName = PFUser.currentUser()!.objectForKey("name") as! String
        let data = [
            "alert" : "New message from \(senderName)",
            "badge" : "Increment"
        ]
        push.setData(data)
        push.sendPushInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("success")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateParent", object: nil)
    }
    
    // Delegate Methods
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return selfAvatar
        }
        
        return incomingAvatar
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView!.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}