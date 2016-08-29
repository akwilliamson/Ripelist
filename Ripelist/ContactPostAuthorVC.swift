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

class ContactPostAuthorVC: JSQMessagesViewController {
    
    let greenColor = UIColor.forestColor()
    let goldColor = UIColor.goldColor()

    var chatRoom: PFObject!
    var postAuthor: PFUser!
    var postObject: PFObject?
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var messageObjects = [PFObject]()
    
    var currentUserBubbleImage: JSQMessagesBubbleImage!
    var currentUserAvatar: JSQMessagesAvatarImage!
    var postAuthorBubbleImage: JSQMessagesBubbleImage!
    var postAuthorAvatar: JSQMessagesAvatarImage!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Messages"
        self.logEvents("Contact Post Author")

        setBubblesAndAvatars()
        
        inputToolbar?.contentView?.leftBarButtonItem = nil
        
        senderId = PFUser.currentUser()?.objectId
        senderDisplayName = PFUser.currentUser()?.username

    }
    
    override func viewWillAppear(animated: Bool) {
        loadMessages()
    }
    
    func setBubblesAndAvatars() {
        currentUserBubbleImage = bubbleImage(withBackgroundColor: goldColor)
        currentUserAvatar = avatarImageWithInitials(forUser: PFUser.currentUser(), withColor: goldColor)
    
        postAuthorBubbleImage = bubbleImage(withBackgroundColor: greenColor)
        postAuthorAvatar = avatarImageWithInitials(forUser: postAuthor, withColor: greenColor)
    }
    
    func bubbleImage(withBackgroundColor color: UIColor) -> JSQMessagesBubbleImage? {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        switch color {
        case goldColor:
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(goldColor)
        case greenColor:
            return bubbleFactory.incomingMessagesBubbleImageWithColor(greenColor)
        default:
            return nil
        }
    }
    
    func avatarImageWithInitials(forUser user: PFUser?, withColor color: UIColor) -> JSQMessagesAvatarImage? {
        guard let username = user?.objectForKey("name") as? NSString else { return nil }
        let firstInitial = username.substringWithRange(NSMakeRange(0,1))
        let avatarFont = UIFont.systemFontOfSize(14)
        let avatarDiameter = UInt(kJSQMessagesCollectionViewAvatarSizeDefault)
        
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(firstInitial, backgroundColor: color, textColor: UIColor.whiteColor(), font: avatarFont, diameter: avatarDiameter)
    }
    
    func loadMessages() {
        if chatRoom.objectId != nil {

            let messageQuery = PFQuery(className: "Message").whereKey("room", equalTo: chatRoom)
            messageQuery.includeKey("user")
            messageQuery.limit = 100
            messageQuery.orderByAscending("createdAt")
            
            messageQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    guard let messages = results as [PFObject]? else { return }
                    
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
    }

// Send Messages
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if chatRoom.objectId == nil {
            chatRoom["user1"] = PFUser.currentUser()
            chatRoom["user2"] = postAuthor
            chatRoom.addObject(postAuthor.objectId!, forKey: "hasUnreadMessages")
            chatRoom["postId"] = postObject
            
            chatRoom.saveInBackgroundWithBlock(nil)
        }
        
        let message = PFObject(className: "Message")
        message["content"] = text
        message["room"] = chatRoom
        message["user"] = PFUser.currentUser()
        
        message.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if error == nil {
                self.loadMessages()
                self.chatRoom["lastUpdate"] = NSDate()
                self.chatRoom.saveInBackgroundWithBlock(nil)
            } else {
                print("error sending message: \(error?.localizedDescription)")
            }
        }
        self.finishSendingMessage()
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: postAuthor)
        
        let push = PFPush()
        push.setQuery(pushQuery)
        let senderName = PFUser.currentUser()!.objectForKey("name") as! String
        let data = ["alert":"New message from \(senderName)", "badge":"Increment"]
        
        push.setData(data)
        push.sendPushInBackground()
    }
    
// Delegate Methods
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        return message.senderId == self.senderId ? currentUserBubbleImage : postAuthorBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        return message.senderId == self.senderId ? currentUserAvatar : postAuthorAvatar
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