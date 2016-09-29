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
    
    var image = UIImage()
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
            NSForegroundColorAttributeName: UIColor.white]
        
        addPhotoButton.layer.cornerRadius = 25
        saveButton.layer.cornerRadius = 25
        
        listingImage.image = postImage?.image
        
        if postImage!.image == UIImage(named: "placeholder.png") {
            addPhotoButton.setTitle("Add Photo", for: UIControlState())
        } else {
            addPhotoButton.setTitle("Change Photo", for: UIControlState())
        }
    }
    
// MARK: - Imagepicker Delegate Methods
    
    // Select or capture an image and save it for listing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let smallerSize = CGSize(width: 480, height: 640) as CGSize
            UIGraphicsBeginImageContext(smallerSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallerSize.width, height: smallerSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageRef = newImage?.cgImage?.cropping(to: CGRect(x: 0, y: 80, width: 480, height: 480))
            let croppedImage = UIImage(cgImage: imageRef!)
            listingImage.image = croppedImage
            addPhotoButton.setTitle("Change Photo", for: UIControlState())
            if let image = listingImage.image {
                self.image = image
            }
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(newImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Display error message if not saved
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo:UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController.photoCouldNotBeSavedAlertController()
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker if cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - Actions
    
    @IBAction func addPhoto(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            }
        }
        
        let choosePhoto = UIAlertAction(title: "Choose Existing", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newMedia = false
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        alert.addAction(takePhoto)
        alert.addAction(choosePhoto)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        delegate?.storeImage(listingImage.image!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        let imageData = UIImagePNGRepresentation(listingImage.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        listingObject["image"] = imageFile
        
        listingObject.saveInBackground { (success, error) in
            if success {
                activityView.stopAnimating()
                self.performSegue(withIdentifier: "UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
