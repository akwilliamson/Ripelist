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
            
            deletedLabel.isHidden = true
            
            inputToolbar!.contentView!.leftBarButtonItem = nil
            
            title = "Messages"
            senderId = PFUser.current()!.objectId
            senderDisplayName = PFUser.current()!.username
            
            let selfUsername = PFUser.current()!.object(forKey: "name") as! NSString
            incomingUser.fetchIfNeededInBackground { (result, error) in
            let incomingUsername = result?.object(forKey: "name") as! NSString
                
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: incomingUsername.substring(with: NSMakeRange(0, 1)), backgroundColor: self.greenColor, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
            
            selfAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: selfUsername.substring(with: NSMakeRange(0, 1)), backgroundColor: goldColor, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: goldColor)
            incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: greenColor)
        } else {
            deletedLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        messageQuery.order(byAscending: "createdAt")
        messageQuery.limit = 20
        messageQuery.includeKey("user")
        
        if lastMessage != nil {
            messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date)
        }
        
        messageQuery.findObjectsInBackground { (results, error) in
            if error == nil {
                if let messages = results as [PFObject]! {
                    for message in messages {
                        self.messageObjects.append(message)
                        
                        let user = message["user"] as! PFUser
                        self.users.append(user)
                        
                        if let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["content"] as! String) {
                            self.messages.append(chatMessage)
                        }
                    }
                    
                    if results!.count != 0 {
                        self.finishReceivingMessage()
                    }

                }
            }
        }
    }
    
    // Send Messages
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = PFObject(className: "Message")
        message["content"] = text
        message["room"] = room
        message["user"] = PFUser.current()
        
        message.saveInBackground { (success, error) in
            if error == nil {
                self.loadMessages()
                self.room["lastUpdate"] = Date()
                self.room.add(self.incomingUser.objectId!, forKey: "hasUnreadMessages")
                self.room.saveInBackground(block: nil)
            } else {
                print("error sending message: \(error!.localizedDescription)")
            }
        }
        self.finishSendingMessage()
        
        // Send push notification to message receiver
       let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: incomingUser)
        
        let push = PFPush()
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?)
        let senderName = PFUser.current()!.object(forKey: "name") as! String
        let data = [
            "alert" : "New message from \(senderName)",
            "badge" : "Increment"
        ]
        push.setData(data)
        push.sendInBackground { (success, error) in
            if success {
                print("success")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateParent"), object: nil)
    }
    
    // Delegate Methods
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return selfAvatar
        }
        
        return incomingAvatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView!.textColor = UIColor.white
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
