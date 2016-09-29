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
    var                     image = UIImage()
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
           listingAddressField.layer.borderColor = greenColor.cgColor
                    staticCity.layer.borderColor = greenColor.cgColor
               listingZipField.layer.borderColor = greenColor.cgColor
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
        
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(CreateListingBViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                       object: nil);
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(CreateListingBViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // If a location pin exists, store it for future reference in the delegate
        if locationPin?.coordinate.latitude != nil {
            delegate?.storePin(self.locationPin)
            // If a location pin exists, set the title of the pin on map button to "Change Pin"
            if locationPin?.coordinate.latitude != 0.0 {
                pinOnMapButton.setTitle("Change Pin", for: UIControlState())
            }
        } else if addressFromCreateListingA == false {
            // If the segue is coming from a view higher on the stack
            
            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", for: UIControlState())
        } else {
            // Set the address field's text to the address string property
            listingAddressField.text = address
            // Set the zip field's text to the zip string property
            listingZipField.text = zip
            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", for: UIControlState())
            // Reset the reference of the address property to not come from Create Request A
            addressFromCreateListingA = false
        }
        if image != nil {
            addPhotoButton.setTitle("Change Photo", for: UIControlState())
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if locationPin != nil {
            pinOnMapButton.setTitle("Change Pin", for: UIControlState())
        }
    }
    
// MARK: - NSNotification Methods
    
    // Slide view up when editing address
    func keyboardWillShow(_ sender: Notification) {
        if self.view.frame.width < 325 {
            if listingAddressField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 67 }, completion: nil)
            } else if listingZipField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 67 }, completion: nil)
            }
        }
    }
    
    // Slide view down when finished editing address
    func keyboardWillHide(_ sender: Notification) {
        if self.view.frame.width < 325 {
            if listingAddressField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 67 }, completion: nil)
            } else if listingZipField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 67 }, completion: nil)
            }
        }
    }
    
// MARK: - Custom Methods
    
    // Validate zip code
    func isZipValid(_ zip: String) -> Bool! {
        if Int(zip) != nil && zip.characters.count == 5 {
            return true
        } else {
            return false
        }
    }
    
// MARK: - Textfield Delegate Methods
    
    // Dismissing keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with:event)
    }
    
    // Dismissing keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    // Clearing text
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    // Did begin
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Remove pin from custom delegate
        locationPin = nil
        delegate?.storePin(locationPin)
        // Set title of pin on map button "Add Pin"
        pinOnMapButton.setTitle("Add Pin", for: UIControlState())
    }
    
    // Did end
    func textFieldDidEndEditing(_ textField: UITextField) {
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
            imageView.image = croppedImage
            addPhotoButton.setTitle("Change Photo", for: UIControlState())
            delegate?.storeImageView(imageView)
            if let image = imageView.image {
                self.image = image
            }
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(newImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Display error message if not saved
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "OK",
                style: .cancel,
                handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker if cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Flurry.logEvent("Cancel Add Photo")
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - Actions
    
    // Persist address to database if valid or remove it from database
    @IBAction func saveAddressTextButton(_ sender: UIButton) {
        let user = PFUser.current()
        if listingAddressField.text != "" && listingZipField.text != "" && saveUserAddress == false {
            saveAddressTextButton.setTitle("Remove Address", for: UIControlState())
            saveUserAddress = true
            if let user = user {
                user["streetAddress"] = listingAddressField.text
                user["cityState"] = "Portland, OR"
                user["zipCode"] = listingZipField.text
                user.saveInBackground(block: nil)
            }
        } else {
            saveAddressTextButton.setTitle("Remember Address", for: UIControlState())
            saveUserAddress = false
            if let user = user {
                user.remove(forKey: "streetAddress")
                user.remove(forKey: "cityState")
                user.remove(forKey: "zipCode")
                user.saveInBackground(block: nil)
            }
        }
    }
    
    // Present alert with proper image picker selections and actions
    @IBAction func addPhotoButton(_ sender: UIButton) {
        print("is there an image saved? -> \(self.image != nil)")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            }
        }
        let choosePhoto = UIAlertAction(title: "Choose Existing", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                Flurry.logEvent("Add Listing Photo")
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
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
    
// MARK: - Segue Methods
    
    // Unwind
    @IBAction func unwindToCreateListingBController(_ segue: UIStoryboardSegue) {
    }
    
    // Validates required information
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "ShowPreview" {
            let invalidAddressFieldController = UIAlertController.invalidAddressAlertController()
            if listingAddressField.text == "" && locationPin == nil {
                self.present(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if listingZipField.text == "" && locationPin == nil {
                self.present(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if isZipValid(listingZipField.text!) == false && locationPin == nil {
                let invalidZipFieldController = UIAlertController.invalidZipAlertController()
                self.present(invalidZipFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        if segue.identifier == "ShowPreview" {
            addressFromCreateListingA = false
            let preview = segue.destination as! CreateListingCViewController
            let addressString = "\(listingAddressField.text) Portland, OR \(listingZipField.text) USA"
            let name = PFUser.current()?.value(forKey: "name") as! String
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
            let navigationController = segue.destination as! UINavigationController
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

