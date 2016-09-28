//
//  RequestDetailsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/27/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import LKAlertController
import ParseUI
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


class RequestDetailsViewController: UIViewController {

// MARK: - Properties
    
    let locationService = LocationService.sharedInstance
    let askingVCForLogin = "AttemptToContactLister"
    
    var localPost: LocalPost!
    var chatRoom: PFObject?
    
// MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swapTypeLabel: UIInsetLabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var nameLabel: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvents("Details of Request")
        setDescriptionHeight()
        addTapGestureOnImageView()
        populateRequestDetails()
        setTimeAgo(atTime: localPost.postObject.updatedAt)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
// MARK: - View Setup Helper Methods
    
    func setDescriptionHeight() {
        descriptionTextField.sizeThatFits(CGSize(width: descriptionTextField.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    func addTapGestureOnImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RequestDetailsViewController.imageTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        image.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func populateRequestDetails() {
        self.titleLabel.text = localPost.getTitle()
        self.descriptionTextField.text = localPost.getDescription()
        
        self.nameLabel.setTitle(localPost.getUsername(), for: UIControlState())
        self.swapTypeLabel.text = localPost.getSwapType()
        self.distanceLabel.text = localPost.getDistance(from: locationService.locationManager.location)
        let location = localPost.getLocation()
        self.mapView.setRegion(latitude: location.latitude, longitude: location.longitude, atSpan: 0.01)
        self.mapView.addOverlay(latitude: location.latitude, longitude: location.longitude)
    }
    
    internal func setTimeAgo(atTime date: Date?) {
        if let date = date {
            self.timeAgoLabel.text = "posted " + date.timeAgoSinceDate()
        }
    }
    
// MARK: - Actions
    
    @IBAction func shareRequest(_ sender: AnyObject) {
        self.logEvents("Share Button Tapped")
        let activityVC = self.createActivityVC(forPost: localPost.postObject)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func contactSeller(_ sender: AnyObject) {
        guard let currentUser = PFUser.current() else {
            presentLogin()
            return
        }
        
        let chatRoomQuery = self.createChatRoomQuery(forCurrentUser: currentUser)
        
        chatRoomQuery.findObjectsInBackground(block: { (fetchedChatRoom: [PFObject]?, error: NSError?) -> Void in
            if error != nil { print(error?.localizedDescription) } else {
                if currentUser.objectId == self.localPost.postAuthor.objectId {
                    self.presentCannotMessageYourselfAlert()
                } else {
                    self.performSegue(withChatRoom: fetchedChatRoom)
                }
            }
        })
    }
    
    fileprivate func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewController(withIdentifier: "onboard_vc")
        present(OnboardVC, animated: true, completion: nil)
    }
    
    @IBAction func nameTapped(_ sender: UIButton) {
        self.logEvents("Name Tapped")
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        self.logEvents("Stars Tapped")
    }
    
// MARK: - Helper Methods
    
    func presentCannotMessageYourselfAlert() {
        let alert = UIAlertController.cannotMessageYourselfController()
        self.present(alert, animated: true, completion: nil)
    }
    
    func createChatRoomQuery(forCurrentUser currentUser: PFUser) -> PFQuery<PFObject> {
        let predicate = NSPredicate(format: "(user1 = %@ AND user2 = %@ AND postId = %@) OR (user1 = %@ AND user2 = %@ AND postId = %@)",
            currentUser, localPost.postAuthor, localPost.postObject, localPost.postAuthor, currentUser, localPost.postObject)
        return PFQuery(className: "Room", predicate: predicate)
    }
    
// MARK: - Segue Methods
    
    func performSegue(withChatRoom chatRoom: [PFObject]?) {
        self.chatRoom = chatRoom?.count > 0 ? chatRoom?.last : PFObject(className: "Room")
        self.performSegue(withIdentifier: "ContactPostAuthor", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if segue.identifier == "ContactPostAuthor" {
            let contactRequesterVC = segue.destination as! ContactPostAuthorVC
            
            contactRequesterVC.postAuthor = localPost.postAuthor
            contactRequesterVC.postObject = localPost.postObject
            contactRequesterVC.chatRoom = chatRoom
        }
    }
    
    @IBAction func unwindToContactLister(_ segue: UIStoryboardSegue) {
    }
}

// MARK: - Extension MKMapView

extension RequestDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleArea = MKCircleRenderer(overlay: overlay)
        circleArea.fillColor = UIColor.purpleRadiusColor()
        return circleArea
    }
}
