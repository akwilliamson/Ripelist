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
        descriptionTextField.sizeThatFits(CGSize(width: descriptionTextField.frame.size.width, height: CGFloat.max))
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
        userImage.userInteractionEnabled = true
        let imageTapped = UITapGestureRecognizer(target: self, action: #selector(ListingDetailsViewController.imageTapped(_:)))
        imageTapped.numberOfTapsRequired = 1
        userImage.addGestureRecognizer(imageTapped)
    }
    
    internal func setTimeAgo(atTime date: NSDate?) {
        if let date = date {
            self.timeAgoLabel.text = "posted " + date.timeAgoSinceDate()
        }
    }
    
    func styleView() {
        setUIStyles()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setUIStyles() {
        descriptionTextField.contentOffset = CGPointMake(0, -220)
    }
    
    func populateListingDetails() {
        populateImage()
        self.titleLabel.text = localPost.getTitle()
        self.descriptionTextField.text = localPost.getDescription()
        self.nameLabel.setTitle(localPost.getUsername(), forState: .Normal)
        populateSwapTypes()
        self.distanceLabel.text = localPost.getDistance(from: locationService.locationManager.location)
        let location = localPost.getLocation()
        self.mapView.setRegion(latitude: location.latitude, longitude: location.longitude, atSpan: 0.01)
        self.mapView.addOverlay(latitude: location.latitude, longitude: location.longitude)
    }
    
    func populateImage() {
        let imageFile = localPost.getImageFile()
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
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
                leftSwapTypeLabel.hidden = true
            }
            
        } else if localPost.forTrade() && localPost.forFree() {
            rightSwapTypeLabel.text! = "Trade"
            leftSwapTypeLabel.text! = "Free"
        } else if localPost.forTrade() {
            rightSwapTypeLabel.text! = "Trade"
            leftSwapTypeLabel.hidden = true
        } else { // for free
            rightSwapTypeLabel.text! = "Free"
            leftSwapTypeLabel.hidden = true
        }
    }
    
    func checkIfViewingWatchlistDetails() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(ListingDetailsViewController.sharePost(_:)))
        if displayedFromWatchlist == false {
            let image = UIImage(named: "favorites.png")
            let favoritesBarButton = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(ListingDetailsViewController.addPostToWatchlist(_:)))
            navigationItem.setRightBarButtonItems([shareBarButton, favoritesBarButton], animated: true)
        } else {
            let trashBarButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(ListingDetailsViewController.removePostFromWatchlist(_:)))
            navigationItem.setRightBarButtonItems([shareBarButton, trashBarButton], animated: true)
        }
        
    }
    
    func sharePost(sender: UIBarButtonItem) {
        self.logEvents("Share Button Tapped")
        let shareString: String!
        let title = localPost.getTitle()
        if title != "No Title" {
            shareString = "Someone is listing: \(title) on Ripelist! Check out ripelist.com to learn more!"
        } else {
            shareString = "Ripelist is a local food marketplace right in your pocket! Check out ripelist.com to learn more!"
        }
        let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
// MARK: Actions
    
    @IBAction func nameTapped(sender: UIButton) {
        self.logEvents("Name Tapped")
        showFeatureAlert().show()
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        self.logEvents("Stars Tapped")
        showFeatureAlert().show()
    }
    
    // MARK: - Custom Methods
    
    func expandThumbnail(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("ShowFullImage", sender: self)
    }
    
    func showFeatureAlert() -> Alert {
        let alert = Alert(title: "User Profile", message: "A feature to see other posts by this user. Should we build it?")
            .addAction("Yes build it now!", style: .Default) { action in
                let feedback = PFObject(className: "Feedback")
                feedback["userProfile"] = true
                feedback["user"] = PFUser.currentUser()
                feedback.saveInBackground()
            }.addAction("Not that important", style: .Default) { action in
                let feedback = PFObject(className: "Feedback")
                feedback["userProfile"] = false
                feedback["user"] = PFUser.currentUser()
                feedback.saveInBackground()
            }.addAction("Cancel", style: .Cancel, handler: nil)
        
        return alert
    }
    
    func removePostFromWatchlist(sender: UIBarButtonItem) {
        activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let listingQuery = findPostFromListingsTable()
        listingQuery.getFirstObjectInBackgroundWithBlock { (listing: PFObject?, error: NSError?) -> Void in
            if let foundListing = listing {
                let alert = Alert(title: "Remove Post", message: "Remove this post from your watchlist?")
                    .addAction("Yes", style: .Default) { action in
                        self.removeListingFromWatchlist(foundListing)
                    }.addAction("No", style: .Cancel, handler: nil)
                alert.show()
            }
        }
    }
    
    func findPostFromListingsTable() -> PFQuery {
        let query = PFQuery(className: "Listing").whereKey("objectId", equalTo: localPost.postObject.objectId!)
        return query
    }
    
    func getRecordFromWatchlist(listing: PFObject) -> PFQuery {
        let query = PFQuery(className: "Watchlist")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("post", equalTo: listing)
        return query
    }
    
    func removeListingFromWatchlist(listing: PFObject) {
        let watchlistQuery = getRecordFromWatchlist(listing)
        watchlistQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
            if let userRecord = results!.first as PFObject! {
                userRecord.deleteInBackground()
                self.navigationController?.popViewControllerAnimated(true)
                self.activityIndicator.hideAnimated(true)
            } else {
                self.activityIndicator.label.text = error?.localizedDescription
                sleep(3)
                self.activityIndicator.hideAnimated(true)
            }
        })
    }
    
    func showAlert(alert: UIAlertController, title: String, message: String) {
        alert.title = title
        alert.message = message
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addPostToWatchlist(sender: UIBarButtonItem) {
        self.logEvents("Add Post To Watchlist")
        let activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alert.addAction(dismissAction)
        // Only try to access Parse record if user is logged in
        if PFUser.currentUser() != nil {
            // Query to see if any Watchlist records exist for the current user
            let query = createWatchlistQuery()
            
            query.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
                // If there are any records, then check them all and see if the selected post has already been added
                if let watchlistItems = results {
                    if watchlistItems.count > 0 {
                        for watchlistItem in watchlistItems {
                            // If the post has already been added, notify the user
                            let postInWatchlist = watchlistItem["post"] as! PFObject
                            if postInWatchlist.objectId! == self.localPost.postObject.objectId {
                                activityIndicator.hideAnimated(false)
                                self.showAlert(alert, title: "Already Added", message: "This post has already been added to your watchlist")
                            }
                        }
                    } else {
                        // If a user record does not exist at all, create one and add the post object
                        let watchlistItem = PFObject(className: "Watchlist")
                        watchlistItem["user"] = PFUser.currentUser()
                        watchlistItem["post"] = self.localPost.postObject
                        watchlistItem.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if success {
                                activityIndicator.hideAnimated(true)
                                self.showAlert(alert, title: "Post Added", message: "This post has been added to your watchlist under the user tab.")
                            } else {
                                activityIndicator.hideAnimated(true)
                                self.showAlert(alert, title: "Error Adding Post", message: error!.localizedDescription)
                            }
                        })
                    }
                }
            })
        } else {
            activityIndicator.hideAnimated(true)
            self.showAlert(alert, title: "No User Found", message: "You must be logged in to add to your watchlist.")
        }
    }
    
    func createWatchlistQuery() -> PFQuery {
        let query = PFQuery(className: "Watchlist")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("post", equalTo: localPost.postObject)
        return query
    }
    
    @IBAction func contactSeller(sender: AnyObject) {
        if let currentUser = PFUser.currentUser() {
            
            let predicate = NSPredicate(format: "(user1 = %@ AND user2 = %@ AND postId = %@) OR (user1 = %@ AND user2 = %@ AND postId = %@)",
                                   currentUser, localPost.postAuthor, localPost.postObject, localPost.postAuthor, currentUser, localPost.postObject)
            let roomQuery = PFQuery(className: "Room", predicate: predicate)
            
            roomQuery.findObjectsInBackgroundWithBlock({ (fetchedChatRoom: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if currentUser.objectId == self.localPost.postAuthor.objectId {
                        let cannotMessageYourselfAlert = UIAlertController.cannotMessageYourselfController()
                        self.presentViewController(cannotMessageYourselfAlert, animated: true, completion: nil)
                    } else {
                        self.chatRoom = fetchedChatRoom?.count > 0 ? fetchedChatRoom?.last : PFObject(className: "Room")
                        self.performSegueWithIdentifier("ContactPostAuthor", sender: self)
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            presentLogin()
        }
    }
    
    private func presentLogin() {
        let loginSB = UIStoryboard(name: "Onboard", bundle: nil)
        let OnboardVC = loginSB.instantiateViewControllerWithIdentifier("onboard_vc")
        presentViewController(OnboardVC, animated: true, completion: nil)
    }
    
// MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        if segue.identifier == "ContactPostAuthor" {
            let contactPostAuthorVC = segue.destinationViewController as! ContactPostAuthorVC
            
            contactPostAuthorVC.postAuthor = localPost.postAuthor
            contactPostAuthorVC.postObject = localPost.postObject
            contactPostAuthorVC.chatRoom = chatRoom
        }
        
        if segue.identifier == "ShowFullImage" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let showFullImageVC = navigationController.topViewController as! ShowFullImageViewController
            showFullImageVC.image = self.listingImageView.image
        }
    }
    
    @IBAction func unwindToContactLister(segue: UIStoryboardSegue) {
    }
}

// MARK: - Delegate Extension: MKMapView

extension ListingDetailsViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = UIColor.purpleRadiusColor()
        return circle
    }
}
