//
//  EditListingViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/18/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class EditRequestViewController: UIViewController {
    
    var requestTitle: String!
    var requestDescription: String?
    var savedDescription: String?
    var delegate: StoreRequestEditsDelegate?
    var requestObject: PFObject!
    
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var   editDescription: UIButton!
    @IBOutlet weak var      editLocation: UIButton!
    @IBOutlet weak var     deleteListing: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Request Main View")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!,
                                                                        NSForegroundColorAttributeName: UIColor.white]
        
        requestTitleLabel.text = requestObject["title"] as? String
        editDescription.layer.cornerRadius = 25
           editLocation.layer.cornerRadius = 25
          deleteListing.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        requestTitleLabel.text = requestObject["title"] as? String
    }
    
    @IBAction func deleteListing(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Listing", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            let listing = self.requestObject
            let chatRoomQuery = PFQuery(className: "Room")
            chatRoomQuery.whereKey("postId", equalTo: PFObject(withoutDataWithClassName: "Listing", objectId: listing?.objectId))
            chatRoomQuery.findObjectsInBackground(block: { (chatRoomResults, error) in
                if chatRoomResults!.count > 0 {
                    let chatRooms = chatRoomResults as [PFObject]!
                    for chatRoom in chatRooms! {
                        let listing = chatRoom["postId"] as! PFObject
                        
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
                        listing.deleteInBackground(block: nil)
                    }
                } else {
                    let listing = self.requestObject
                    listing?.deleteInBackground(block: nil)
                }
            })
            self.performSegue(withIdentifier: "UnwindToPosts", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel,handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToEditListing(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditRequestDescription" {
            let navigationController = segue.destination as! UINavigationController
            let editRequestDescriptionVC = navigationController.topViewController as! EditRequestDescriptionViewController
            editRequestDescriptionVC.requestTitle = requestTitleLabel.text
            if let description = requestDescription {
                editRequestDescriptionVC.delegate = delegate
                editRequestDescriptionVC.requestObject = requestObject
                editRequestDescriptionVC.requestDescription = description
            }
        }
        if segue.identifier == "EditRequestLocation" {
            let navigationController = segue.destination as! UINavigationController
            let editRequestLocationVC = navigationController.topViewController as! EditRequestLocationViewController
            editRequestLocationVC.delegate = delegate
            editRequestLocationVC.requestObject = requestObject
        }
    }
}
