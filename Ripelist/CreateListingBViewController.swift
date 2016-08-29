//
//  CreateListingBViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices
import ParseUI
import Flurry_iOS_SDK

class CreateListingBViewController: UIViewController,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    UITextFieldDelegate {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    let  goldColor = UIColor.goldColor()
    
// MARK: - Variables
    
    var              listingTitle: String?
    var           listingCategory: String?
    var              listingPrice: String?
    var             listingAmount: String?
    var        listingDescription: String?
    var                   address: String?
    var                       zip: String?
    var                  forTrade: Bool?
    var                   forFree: Bool?
    var                  newMedia: Bool?
    var               locationPin: MKPointAnnotation?
    var                 placemark: CLPlacemark?
    var          possibleLocation: CLLocationCoordinate2D?
    var                  delegate: CreateListingBViewControllerDelegate?
    var                     image = UIImage?()
    var           saveUserAddress = false
    var            isValidAddress = true
    var addressFromCreateListingA = false
    var       shouldRemoveLastPin = false
    
// MARK: - Outlets
    
    // Views
    @IBOutlet weak var        listingAddressField: UITextField!
    @IBOutlet weak var             cityStateField: UITextField!
    @IBOutlet weak var            listingZipField: UITextField!
    @IBOutlet weak var                 staticCity: UITextField!
    @IBOutlet weak var             addPhotoButton: UIButton!
    @IBOutlet weak var             pinOnMapButton: UIButton!
    @IBOutlet weak var      saveAddressTextButton: UIButton!
    @IBOutlet weak var                 nextButton: UIButton!
    @IBOutlet weak var                  imageView: UIImageView!
    // Constraints
    @IBOutlet weak var               addPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var                addressHeight: NSLayoutConstraint!
    @IBOutlet weak var                   cityHeight: NSLayoutConstraint!
    @IBOutlet weak var                    zipHeight: NSLayoutConstraint!
    @IBOutlet weak var                 addPinHeight: NSLayoutConstraint!
    @IBOutlet weak var           addPhotoTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var      locationLabelTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var            orLabelTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var         orLabelBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var rememberAddressTopConstraint: NSLayoutConstraint!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Create Listing B")
           listingAddressField.layer.borderColor = greenColor.CGColor
                    staticCity.layer.borderColor = greenColor.CGColor
               listingZipField.layer.borderColor = greenColor.CGColor
           listingAddressField.layer.borderWidth = 2
                    staticCity.layer.borderWidth = 2
               listingZipField.layer.borderWidth = 2
        
               addPhotoButton.layer.cornerRadius = 25
        saveAddressTextButton.layer.cornerRadius = 20
               pinOnMapButton.layer.cornerRadius = 25
                   nextButton.layer.cornerRadius = 25
        
        listingAddressField.delegate = self
            listingZipField.delegate = self
        
        listingAddressField.text = address
            listingZipField.text = zip
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(CreateListingBViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                       object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(CreateListingBViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                       object: nil);
    }
    
    override func viewDidLayoutSubviews() {
        if self.view.frame.width > 320 {
                        addPhotoHeight.constant = 50
                         addressHeight.constant = 50
                            cityHeight.constant = 50
                             zipHeight.constant = 50
                          addPinHeight.constant = 50
               locationLabelTopSpacing.constant = 50
                     orLabelTopSpacing.constant = 20
                  orLabelBottomSpacing.constant = 20
                    addPhotoTopSpacing.constant = 40
          rememberAddressTopConstraint.constant = 10
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // If a location pin exists, store it for future reference in the delegate
        if locationPin?.coordinate.latitude != nil {
            delegate?.storePin(self.locationPin)
            // If a location pin exists, set the title of the pin on map button to "Change Pin"
            if locationPin?.coordinate.latitude != 0.0 {
                pinOnMapButton.setTitle("Change Pin", forState: .Normal)
            }
        } else if addressFromCreateListingA == false {
            // If the segue is coming from a view higher on the stack
            
            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", forState: .Normal)
        } else {
            // Set the address field's text to the address string property
            listingAddressField.text = address
            // Set the zip field's text to the zip string property
            listingZipField.text = zip
            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", forState: .Normal)
            // Reset the reference of the address property to not come from Create Request A
            addressFromCreateListingA = false
        }
        if image != nil {
            addPhotoButton.setTitle("Change Photo", forState: .Normal)
        }
    }

    override func viewDidAppear(animated: Bool) {
        if locationPin != nil {
            pinOnMapButton.setTitle("Change Pin", forState: .Normal)
        }
    }
    
// MARK: - NSNotification Methods
    
    // Slide view up when editing address
    func keyboardWillShow(sender: NSNotification) {
        if self.view.frame.width < 325 {
            if listingAddressField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 67 }, completion: nil)
            } else if listingZipField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 67 }, completion: nil)
            }
        }
    }
    
    // Slide view down when finished editing address
    func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.width < 325 {
            if listingAddressField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 67 }, completion: nil)
            } else if listingZipField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 67 }, completion: nil)
            }
        }
    }
    
// MARK: - Custom Methods
    
    // Validate zip code
    func isZipValid(zip: String) -> Bool! {
        if Int(zip) != nil && zip.characters.count == 5 {
            return true
        } else {
            return false
        }
    }
    
// MARK: - Textfield Delegate Methods
    
    // Dismissing keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    // Dismissing keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    // Clearing text
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return false
    }
    
    // Did begin
    func textFieldDidBeginEditing(textField: UITextField) {
        // Remove pin from custom delegate
        locationPin = nil
        delegate?.storePin(locationPin)
        // Set title of pin on map button "Add Pin"
        pinOnMapButton.setTitle("Add Pin", forState: .Normal)
    }
    
    // Did end
    func textFieldDidEndEditing(textField: UITextField) {
        if delegate != nil {
            if textField.tag == 1 {
                delegate?.storeAddress(self.listingAddressField.text)
            } else {
                delegate?.storeZip(self.listingZipField.text)
            }
        }
        if textField.text == "" {
            shouldRemoveLastPin = false
        } else {
            shouldRemoveLastPin = true
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
            imageView.image = croppedImage
            addPhotoButton.setTitle("Change Photo", forState: .Normal)
            delegate?.storeImageView(imageView)
            self.image = imageView.image
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(CreateListingBViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Display error message if not saved
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel,
                handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker if cancelled
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        Flurry.logEvent("Cancel Add Photo")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - Actions
    
    // Persist address to database if valid or remove it from database
    @IBAction func saveAddressTextButton(sender: UIButton) {
        let user = PFUser.currentUser()
        if listingAddressField.text != "" && listingZipField.text != "" && saveUserAddress == false {
            saveAddressTextButton.setTitle("Remove Address", forState: .Normal)
            saveUserAddress = true
            if let user = user {
                user["streetAddress"] = listingAddressField.text
                user["cityState"] = "Portland, OR"
                user["zipCode"] = listingZipField.text
                user.saveInBackgroundWithBlock(nil)
            }
        } else {
            saveAddressTextButton.setTitle("Remember Address", forState: .Normal)
            saveUserAddress = false
            if let user = user {
                user.removeObjectForKey("streetAddress")
                user.removeObjectForKey("cityState")
                user.removeObjectForKey("zipCode")
                user.saveInBackgroundWithBlock(nil)
            }
        }
    }
    
    // Present alert with proper image picker selections and actions
    @IBAction func addPhotoButton(sender: UIButton) {
        print("is there an image saved? -> \(self.image != nil)")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            }
        }
        let choosePhoto = UIAlertAction(title: "Choose Existing", style: .Default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                Flurry.logEvent("Add Listing Photo")
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
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
    
// MARK: - Segue Methods
    
    // Unwind
    @IBAction func unwindToCreateListingBController(segue: UIStoryboardSegue) {
    }
    
    // Validates required information
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ShowPreview" {
            let invalidAddressFieldController = UIAlertController.invalidAddressAlertController()
            if listingAddressField.text == "" && locationPin == nil {
                self.presentViewController(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if listingZipField.text == "" && locationPin == nil {
                self.presentViewController(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if isZipValid(listingZipField.text!) == false && locationPin == nil {
                let invalidZipFieldController = UIAlertController.invalidZipAlertController()
                self.presentViewController(invalidZipFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        if segue.identifier == "ShowPreview" {
            addressFromCreateListingA = false
            let preview = segue.destinationViewController as! CreateListingCViewController
            let addressString = "\(listingAddressField.text) Portland, OR \(listingZipField.text) USA"
            let name = PFUser.currentUser()?.valueForKey("name") as! String
                 preview.addressString = addressString
                          preview.name = name
                       preview.zipCode = listingZipField.text
                   preview.homeAddress = listingAddressField.text
                  preview.listingTitle = listingTitle
               preview.listingCategory = listingCategory
                  preview.listingPrice = listingPrice
                 preview.listingAmount = listingAmount
            preview.listingDescription = listingDescription
                         preview.image = image
                   preview.locationPin = locationPin
                      preview.forTrade = forTrade
                       preview.forFree = forFree
        }
        if segue.identifier == "AddPinToMap" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let putPinOnListingMapViewController = navigationController.topViewController as! PutPinOnListingMapViewController
            putPinOnListingMapViewController.shouldRemoveLastPin = shouldRemoveLastPin
            if locationPin != nil {
                putPinOnListingMapViewController.lastPin = [locationPin!]
            } else {
                putPinOnListingMapViewController.address = listingAddressField.text
                putPinOnListingMapViewController.zip = listingZipField.text
            }
        }
    }
}

