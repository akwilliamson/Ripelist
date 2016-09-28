//
//  EditListingViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class EditListingViewController: UIViewController {
    
    var listingTitle: String!
    var listingImage: UIImageView!
    var listingDescription: String?
    var savedDescription: String?
    var delegate: StoreListingEditsDelegate?
    var listingObject: PFObject!

    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var   editDescription: UIButton!
    @IBOutlet weak var         editPhoto: UIButton!
    @IBOutlet weak var      editLocation: UIButton!
    @IBOutlet weak var     deleteListing: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Listing Main View")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!,
                                                                        NSForegroundColorAttributeName: UIColor.white]
        
        listingTitleLabel.text = listingObject["title"] as? String
        editDescription.layer.cornerRadius = 25
              editPhoto.layer.cornerRadius = 25
           editLocation.layer.cornerRadius = 25
          deleteListing.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listingTitleLabel.text = listingObject["title"] as? String
    }
    
    @IBAction func deleteListing(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Listing", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            let listing = self.listingObject
            let chatRoomQuery = PFQuery(className: "Room")
            chatRoomQuery.whereKey("postId", equalTo: PFObject(withoutDataWithClassName: "Listing", objectId: listing?.objectId))
            chatRoomQuery.findObjectsInBackground(block: { (chatRoomResults: [PFObject]?, error: NSError?) -> Void in
                if chatRoomResults!.count > 0 {
                    let chatRooms = chatRoomResults as [PFObject]!
                    for chatRoom in chatRooms {
                        let listing = chatRoom["postId"] as! PFObject
                        
                        let messagesQuery = PFQuery(className: "Message")
                        messagesQuery.whereKey("room", equalTo: PFObject(withoutDataWithClassName: "Room", objectId: chatRoom.objectId))
                        messagesQuery.findObjectsInBackground(block: { (results: [PFObject]?, error: NSError?) -> Void in
                            if results != nil {
                                let messages = results as [PFObject]!
                                for result in messages {
                                    result.deleteInBackground(block: nil)
                                }
                            }
                        })
                        chatRoom.deleteInBackground(block: nil)
                        listing.deleteInBackground(block: nil)
                    }
                } else {
                    let listing = self.listingObject
                    listing.deleteInBackground(block: nil)
                }
            })
            self.performSegue(withIdentifier: "UnwindToPosts", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToEditListing(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditListingDescription" {
            let navigationController = segue.destination as! UINavigationController
            let editListingDescriptionVC = navigationController.topViewController as! EditListingDescriptionViewController
            editListingDescriptionVC.listingTitle = listingTitleLabel.text
            if let description = listingDescription {
                editListingDescriptionVC.delegate = delegate
                editListingDescriptionVC.listingObject = listingObject
                editListingDescriptionVC.listingDescription = description
            }
        }
        if segue.identifier == "EditListingPhoto" {
            let navigationController = segue.destination as! UINavigationController
            let editListingPhotoVC = navigationController.topViewController as! EditListingPhotoViewController
            editListingPhotoVC.delegate = delegate
            editListingPhotoVC.listingObject = listingObject
            editListingPhotoVC.postImage = listingImage
        }
        if segue.identifier == "EditListingLocation" {
            let navigationController = segue.destination as! UINavigationController
            let editListingLocationVC = navigationController.topViewController as! EditListingLocationViewController
            editListingLocationVC.delegate = delegate
            editListingLocationVC.listingObject = listingObject
        }
    }
}
