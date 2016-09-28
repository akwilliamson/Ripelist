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
        
        senderId = PFUser.current()?.objectId
        senderDisplayName = PFUser.current()?.username

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMessages()
    }
    
    func setBubblesAndAvatars() {
        currentUserBubbleImage = bubbleImage(withBackgroundColor: goldColor)
        currentUserAvatar = avatarImageWithInitials(forUser: PFUser.current(), withColor: goldColor)
    
        postAuthorBubbleImage = bubbleImage(withBackgroundColor: greenColor)
        postAuthorAvatar = avatarImageWithInitials(forUser: postAuthor, withColor: greenColor)
    }
    
    func bubbleImage(withBackgroundColor color: UIColor) -> JSQMessagesBubbleImage? {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        switch color {
        case goldColor:
            return bubbleFactory?.outgoingMessagesBubbleImage(with: goldColor)
        case greenColor:
            return bubbleFactory?.incomingMessagesBubbleImage(with: greenColor)
        default:
            return nil
        }
    }
    
    func avatarImageWithInitials(forUser user: PFUser?, withColor color: UIColor) -> JSQMessagesAvatarImage? {
        guard let username = user?.object(forKey: "name") as? NSString else { return nil }
        let firstInitial = username.substring(with: NSMakeRange(0,1))
        let avatarFont = UIFont.systemFont(ofSize: 14)
        let avatarDiameter = UInt(kJSQMessagesCollectionViewAvatarSizeDefault)
        
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: firstInitial, backgroundColor: color, textColor: UIColor.white, font: avatarFont, diameter: avatarDiameter)
    }
    
    func loadMessages() {
        if chatRoom.objectId != nil {

            let messageQuery = PFQuery(className: "Message").whereKey("room", equalTo: chatRoom)
            messageQuery.includeKey("user")
            messageQuery.limit = 100
            messageQuery.order(byAscending: "createdAt")
            
            messageQuery.findObjectsInBackground { (results: [PFObject]?, error: NSError?) -> Void in
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
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if chatRoom.objectId == nil {
            chatRoom["user1"] = PFUser.current()
            chatRoom["user2"] = postAuthor
            chatRoom.add(postAuthor.objectId!, forKey: "hasUnreadMessages")
            chatRoom["postId"] = postObject
            
            chatRoom.saveInBackground(block: nil)
        }
        
        let message = PFObject(className: "Message")
        message["content"] = text
        message["room"] = chatRoom
        message["user"] = PFUser.current()
        
        message.saveInBackground { (success:Bool, error:NSError?) -> Void in
            if error == nil {
                self.loadMessages()
                self.chatRoom["lastUpdate"] = Date()
                self.chatRoom.saveInBackground(block: nil)
            } else {
                print("error sending message: \(error?.localizedDescription)")
            }
        }
        self.finishSendingMessage()
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: postAuthor)
        
        let push = PFPush()
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?)
        let senderName = PFUser.current()!.object(forKey: "name") as! String
        let data = ["alert":"New message from \(senderName)", "badge":"Increment"]
        
        push.setData(data)
        push.sendInBackground()
    }
    
// Delegate Methods
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        return message.senderId == self.senderId ? currentUserBubbleImage : postAuthorBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        return message.senderId == self.senderId ? currentUserAvatar : postAuthorAvatar
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
