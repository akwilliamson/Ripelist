//
//  ListingDetailsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/26/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import LKAlertController
import MBProgressHUD
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


class ListingDetailsViewController: UIViewController {
    
// MARK: - Properties
    
    let locationService = LocationService.sharedInstance
    let askingVCForLogin = "AttemptToContactLister"
    
    var localPost: LocalPost!
    var chatRoom: PFObject?
    
    var displayedFromWatchlist = false
    var activityIndicator = MBProgressHUD()
    
// MARK: - Outlets

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var listingImageView: PFImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightSwapTypeLabel: UIInsetLabel!
    @IBOutlet weak var leftSwapTypeLabel: UIInsetLabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var nameLabel: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - View Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvents("Details of Listing")
        setDescriptionHeight()
        addTapGestureRecognizers()
        populateListingDetails()
        styleView()
        checkIfViewingWatchlistDetails()
        setTimeAgo(atTime: localPost.postObject.updatedAt)
    }
    
// MARK: - View Setup Helper Methods
    
    func setDescriptionHeight() {
        descriptionTextField.sizeThatFits(CGSize(width: descriptionTextField.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    func addTapGestureRecognizers() {
        addPhotoGesture()
        addUserImageGesture()
    }
    
    func addPhotoGesture() {
        let thumbnailTap = UITapGestureRecognizer(target: self, action: #selector(ListingDetailsViewController.expandThumbnail(_:)))
        thumbnailTap.numberOfTapsRequired = 1
        listingImageView?.addGestureRecognizer(thumbnailTap)
    }
    
    func addUserImageGesture() {
        userImage.isUserInteractionEnabled = true
        let imageTapped = UITapGestureRecognizer(target: self, action: #selector(ListingDetailsViewController.imageTapped(_:)))
        imageTapped.numberOfTapsRequired = 1
        userImage.addGestureRecognizer(imageTapped)
    }
    
    internal func setTimeAgo(atTime date: Date?) {
        if let date = date {
            self.timeAgoLabel.text = "posted " + date.timeAgoSinceDate()
        }
    }
    
    func styleView() {
        setUIStyles()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setUIStyles() {
        descriptionTextField.contentOffset = CGPoint(x: 0, y: -220)
    }
    
    func populateListingDetails() {
        populateImage()
        self.titleLabel.text = localPost.getTitle()
        self.descriptionTextField.text = localPost.getDescription()
        self.nameLabel.setTitle(localPost.getUsername(), for: UIControlState())
        populateSwapTypes()
        self.distanceLabel.text = localPost.getDistance(from: locationService.locationManager.location)
        let location = localPost.getLocation()
        self.mapView.setRegion(latitude: location.latitude, longitude: location.longitude, atSpan: 0.01)
        self.mapView.addOverlay(latitude: location.latitude, longitude: location.longitude)
    }
    
    func populateImage() {
        let imageFile = localPost.getImageFile()
        if let imageFile = imageFile {
            imageFile.getDataInBackground(block: { (data, error) in
                if let data = data {
                    self.listingImageView.image = UIImage(data: data)
                }
            })
        } else {
            listingImageView.image = UIImage(named: "placeholder.png")
        }
    }
    
    func populateSwapTypes() {
        if let price = localPost.getPrice() {
            let amountType = localPost.getAmountType()
            rightSwapTypeLabel.text! = amountType == nil ? "$\(price)" : "$\(price)/\(amountType!)"
            
            if localPost.forTrade() { // For sale & trade
                leftSwapTypeLabel.text! = "Trade"
            } else { // Only for sale
                leftSwapTypeLabel.isHidden = true
            }
            
        } else if localPost.forTrade() && localPost.forFree() {
            rightSwapTypeLabel.text! = "Trade"
            leftSwapTypeLabel.text! = "Free"
        } else if localPost.forTrade() {
            rightSwapTypeLabel.text! = "Trade"
            leftSwapTypeLabel.isHidden = true
        } else { // for free
            rightSwapTypeLabel.text! = "Free"
            leftSwapTypeLabel.isHidden = true
        }
    }
    
    func checkIfViewingWatchlistDetails() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ListingDetailsViewController.sharePost(_:)))
        if displayedFromWatchlist == false {
            let image = UIImage(named: "favorites.png")
            let favoritesBarButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(ListingDetailsViewController.addPostToWatchlist(_:)))
            navigationItem.setRightBarButtonItems([shareBarButton, favoritesBarButton], animated: true)
        } else {
            let trashBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ListingDetailsViewController.removePostFromWatchlist(_:)))
            navigationItem.setRightBarButtonItems([shareBarButton, trashBarButton], animated: true)
        }
        
    }
    
    func sharePost(_ sender: UIBarButtonItem) {
        self.logEvents("Share Button Tapped")
        let shareString: String!
        let title = localPost.getTitle()
        if title != "No Title" {
            shareString = "Someone is listing: \(title) on Ripelist! Check out ripelist.com to learn more!"
        } else {
            shareString = "Ripelist is a local food marketplace right in your pocket! Check out ripelist.com to learn more!"
        }
        let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
// MARK: Actions
    
    @IBAction func nameTapped(_ sender: UIButton) {
        self.logEvents("Name Tapped")
        showFeatureAlert().show()
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        self.logEvents("Stars Tapped")
        showFeatureAlert().show()
    }
    
    // MARK: - Custom Methods
    
    func expandThumbnail(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "ShowFullImage", sender: self)
    }
    
    func showFeatureAlert() -> Alert {
        let alert = Alert(title: "User Profile", message: "A feature to see other posts by this user. Should we build it?")
            .addAction("Yes build it now!", style: .default) { action in
                let feedback = PFObject(className: "Feedback")
                feedback["userProfile"] = true
                feedback["user"] = PFUser.current()
                feedback.saveInBackground()
            }.addAction("Not that important", style: .default) { action in
                let feedback = PFObject(className: "Feedback")
                feedback["userProfile"] = false
                feedback["user"] = PFUser.current()
                feedback.saveInBackground()
            }.addAction("Cancel", style: .cancel, handler: nil)
        
        return alert
    }
    
    func removePostFromWatchlist(_ sender: UIBarButtonItem) {
        activityIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)

        let listingQuery = findPostFromListingsTable()
        listingQuery.getFirstObjectInBackground { (listing: PFObject?, error: NSError?) -> Void in
            if let foundListing = listing {
                let alert = Alert(title: "Remove Post", message: "Remove this post from your watchlist?")
                    .addAction("Yes", style: .default) { action in
                        self.removeListingFromWatchlist(foundListing)
                    }.addAction("No", style: .cancel, handler: nil)
                alert.show()
            }
        }
    }
    
    func findPostFromListingsTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Listing").whereKey("objectId", equalTo: localPost.postObject.objectId!)
        return query
    }
    
    func getRecordFromWatchlist(_ listing: PFObject) -> PFQuery<PFObject> {
        let query = PFQuery(className: "Watchlist")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.whereKey("post", equalTo: listing)
        return query
    }
    
    func removeListingFromWatchlist(_ listing: PFObject) {
        let watchlistQuery = getRecordFromWatchlist(listing)
        watchlistQuery.findObjectsInBackground(block: { (results: [PFObject]?, error: NSError?) -> Void in
            if let userRecord = results!.first as PFObject! {
                userRecord.deleteInBackground()
                self.navigationController?.popViewController(animated: true)
                self.activityIndicator.hide(animated: true)
            } else {
                self.activityIndicator.label.text = error?.localizedDescription
                sleep(3)
                self.activityIndicator.hide(animated: true)
            }
        })
    }
    
    func showAlert(_ alert: UIAlertController, title: String, message: String) {
        alert.title = title
        alert.message = message
        self.present(alert, animated: true, completion: nil)
    }
    
    func addPostToWatchlist(_ sender: UIBarButtonItem) {
        self.logEvents("Add Post To Watchlist")
        let activityIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        // Only try to access Parse record if user is logged in
        if PFUser.current() != nil {
            // Query to see if any Watchlist records exist for the current user
            let query = createWatchlistQuery()
            
            query.findObjectsInBackground(block: { (results: [PFObject]?, error: NSError?) -> Void in
                // If there are any records, then check them all and see if the selected post has already been added
                if let watchlistItems = results {
                    if watchlistItems.count > 0 {
                        for watchlistItem in watchlistItems {
                            // If the post has already been added, notify the user
                            let postInWatchlist = watchlistItem["post"] as! PFObject
                            if postInWatchlist.objectId! == self.localPost.postObject.objectId {
                                activityIndicator.hide(animated: false)
                                self.showAlert(alert, title: "Already Added", message: "This post has already been added to your watchlist")
                            }
                        }
                    } else {
                        // If a user record does not exist at all, create one and add the post object
                        let watchlistItem = PFObject(className: "Watchlist")
                        watchlistItem["user"] = PFUser.current()
                        watchlistItem["post"] = self.localPost.postObject
                        watchlistItem.saveInBackground(block: { (success: Bool, error: NSError?) -> Void in
                            if success {
                                activityIndicator.hide(animated: true)
                                self.showAlert(alert, title: "Post Added", message: "This post has been added to your watchlist under the user tab.")
                            } else {
                                activityIndicator.hide(animated: true)
                                self.showAlert(alert, title: "Error Adding Post", message: error!.localizedDescription)
                            }
                        })
                    }
                }
            })
        } else {
            activityIndicator.hide(animated: true)
            self.showAlert(alert, title: "No User Found", message: "You must be logged in to add to your watchlist.")
        }
    }
    
    func createWatchlistQuery() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Watchlist")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.whereKey("post", equalTo: localPost.postObject)
        return query
    }
    
    @IBAction func contactSeller(_ sender: AnyObject) {
        if let currentUser = PFUser.current() {
            
            let predicate = NSPredicate(format: "(user1 = %@ AND user2 = %@ AND postId = %@) OR (user1 = %@ AND user2 = %@ AND postId = %@)",
                                   currentUser, localPost.postAuthor, localPost.postObject, localPost.postAuthor, currentUser, localPost.postObject)
            let roomQuery = PFQuery(className: "Room", predicate: predicate)
            
            roomQuery.findObjectsInBackground(block: { (fetchedChatRoom: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if currentUser.objectId == self.localPost.postAuthor.objectId {
                        let cannotMessageYourselfAlert = UIAlertController.cannotMessageYourselfController()
                        self.present(cannotMessageYourselfAlert, animated: true, completion: nil)
                    } else {
                        self.chatRoom = fetchedChatRoom?.count > 0 ? fetchedChatRoom?.last : PFObject(className: "Room")
                        self.performSegue(withIdentifier: "ContactPostAuthor", sender: self)
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            presentLogin()
        }
    }
    
    fileprivate func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewController(withIdentifier: "onboard_vc")
        present(OnboardVC, animated: true, completion: nil)
    }
    
// MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if segue.identifier == "ContactPostAuthor" {
            let contactPostAuthorVC = segue.destination as! ContactPostAuthorVC
            
            contactPostAuthorVC.postAuthor = localPost.postAuthor
            contactPostAuthorVC.postObject = localPost.postObject
            contactPostAuthorVC.chatRoom = chatRoom
        }
        
        if segue.identifier == "ShowFullImage" {
            let navigationController = segue.destination as! UINavigationController
            let showFullImageVC = navigationController.topViewController as! ShowFullImageViewController
            showFullImageVC.image = self.listingImageView.image
        }
    }
    
    @IBAction func unwindToContactLister(_ segue: UIStoryboardSegue) {
    }
}

// MARK: - Delegate Extension: MKMapView

extension ListingDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = UIColor.purpleRadiusColor()
        return circle
    }
}
