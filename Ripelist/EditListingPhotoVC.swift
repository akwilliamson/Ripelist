//
//  EditListingPhotoViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MobileCoreServices
import ParseUI
import Flurry_iOS_SDK

class EditListingPhotoViewController: UIViewController,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate {
    
    var postImage: UIImageView?
    var delegate: StoreListingEditsDelegate?
    var listingObject: PFObject!
    
    var image = UIImage?()
    var newMedia: Bool?
    
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Listing Photo")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold",
            size: 25)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        addPhotoButton.layer.cornerRadius = 25
        saveButton.layer.cornerRadius = 25
        
        listingImage.image = postImage?.image
        
        if postImage!.image == UIImage(named: "placeholder.png") {
            addPhotoButton.setTitle("Add Photo", forState: .Normal)
        } else {
            addPhotoButton.setTitle("Change Photo", forState: .Normal)
        }
    }
    
// MARK: - Imagepicker Delegate Methods
    
    // Select or capture an image and save it for listing
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let smallerSize = CGSizeMake(480, 640) as CGSize
            UIGraphicsBeginImageContext(smallerSize)
            image.drawInRect(CGRectMake(0, 0, smallerSize.width, smallerSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageRef = CGImageCreateWithImageInRect(newImage.CGImage, CGRectMake(0, 80, 480, 480))
            let croppedImage = UIImage(CGImage: imageRef!)
            listingImage.image = croppedImage
            addPhotoButton.setTitle("Change Photo", forState: .Normal)
            self.image = listingImage.image
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(EditListingPhotoViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Display error message if not saved
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            let alert = UIAlertController.photoCouldNotBeSavedAlertController()
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker if cancelled
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - Actions
    
    @IBAction func addPhoto(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            }
        }
        
        let choosePhoto = UIAlertAction(title: "Choose Existing", style: .Default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newMedia = false
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(takePhoto)
        alert.addAction(choosePhoto)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        delegate?.storeImage(listingImage.image!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.transform = CGAffineTransformMakeScale(2, 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        let imageData = UIImagePNGRepresentation(listingImage.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        listingObject["image"] = imageFile
        
        listingObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                activityView.stopAnimating()
                self.performSegueWithIdentifier("UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
