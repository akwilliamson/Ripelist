//
//  CreateRequestBViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import MapKit
import ParseUI
import Flurry_iOS_SDK

class CreateRequestBViewController: UIViewController,
                                    UITextFieldDelegate,
                                    UINavigationControllerDelegate {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    //
    let user = PFUser.currentUser()
    
// MARK: - Variables
    
    // Custom delegate for saving address, zip and location pin
    var delegate: CreateRequestBViewControllerDelegate?
    // Data passed on from Create Request A
    var       requestTitle: String!
    var    requestCategory: String!
    var    requestSwapType: String!
    var requestDescription: String?
    // ?
    var address: String?
    var     zip: String?
    // ?
    var           saveUserAddress = false
    var addressFromCreateRequestA = false
    var       shouldRemoveLastPin = false
    // To store location pin if it exists
    var locationPin: MKPointAnnotation?
    
// MARK: - Outlets
    
    @IBOutlet weak var requestAddressField: TextField!
    @IBOutlet weak var     requestZipField: TextField!
    @IBOutlet weak var           cityField: UITextField!
    @IBOutlet weak var   saveAddressButton: UIButton!
    @IBOutlet weak var      pinOnMapButton: UIButton!
    @IBOutlet weak var          nextButton: UIButton!
    //Constraints
    @IBOutlet weak var                   orLabelTop: NSLayoutConstraint!
    @IBOutlet weak var              addPinButtonTop: NSLayoutConstraint!
    @IBOutlet weak var rememberAddressTopConstraint: NSLayoutConstraint!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Create Request B")
        // Customize views for buttons and text fields
         saveAddressButton.layer.cornerRadius = 20
            pinOnMapButton.layer.cornerRadius = 25
                nextButton.layer.cornerRadius = 25
        requestAddressField.layer.borderWidth = 2
                  cityField.layer.borderWidth = 2
            requestZipField.layer.borderWidth = 2
        requestAddressField.layer.borderColor = greenColor.CGColor
                  cityField.layer.borderColor = greenColor.CGColor
            requestZipField.layer.borderColor = greenColor.CGColor
        
        // Set textfield delegates
        requestAddressField.delegate = self
            requestZipField.delegate = self
        
        requestAddressField.text = address
            requestZipField.text = zip
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
        } else if addressFromCreateRequestA == false {
            // If the segue is coming from a view higher on the stack

            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", forState: .Normal)
        } else {
            // Set the address field's text to the address string property
            requestAddressField.text = address
            // Set the zip field's text to the zip string property
            requestZipField.text = zip
            // If a location pin doesn't exist, set the title of the pin on map button to "Add Pin"
            pinOnMapButton.setTitle("Add Pin", forState: .Normal)
            // Reset the reference of the address property to not come from Create Request A
            addressFromCreateRequestA = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.view.frame.width > 325 {
                              orLabelTop.constant = 20
                         addPinButtonTop.constant = 40
            rememberAddressTopConstraint.constant = 15
        }
    }
    
// Text Field Editing Methods
    
    // Dismiss keyboard methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }

    // Dismiss keyboard methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    // Text fields should not clear when touched
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return false
    }
    
    // When address is being edited, the location pin is removed from memory and related views
    func textFieldDidBeginEditing(textField: UITextField) {
        if self.view.frame.width < 325 {
            UIView.animateWithDuration(0.3, animations: { self.view.frame.origin.y -= 27 }, completion: nil)
        }
        // Remove pin from custom delegate
        locationPin = nil
        delegate?.storePin(locationPin)
        // Set title of pin on map button "Add Pin"
        pinOnMapButton.setTitle("Add Pin", forState: .Normal)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.view.frame.width < 325 {
            UIView.animateWithDuration(0.3, animations: { self.view.frame.origin.y += 27 }, completion: nil)
        }
        // If a delegate exists for the text field, store the value in custom delegate when finished editing
        if delegate != nil {
            if textField.tag == 1 {
                delegate?.storeAddress(self.requestAddressField.text)
            } else {
                delegate?.storeZip(self.requestZipField.text)
            }
        }
        if textField.text == "" {
            shouldRemoveLastPin = false
        } else {
            shouldRemoveLastPin = true
        }
    }
    
// Custom Methods
    
    // Check if zip code is valid
    func isZipValid(zip: String) -> Bool! {
        return Int(zip) != nil && zip.characters.count == 5 ? true : false
    }
    
// Action Methods
    
    @IBAction func saveAddressButton(sender: UIButton) {
        requestAddressField.resignFirstResponder()
        requestZipField.resignFirstResponder()
        let user = PFUser.currentUser()
        if requestAddressField.text != "" && requestZipField.text != "" && saveUserAddress == false {
            saveAddressButton.setTitle("Remove Address", forState: .Normal)
            saveUserAddress = true
            user?["streetAddress"] = requestAddressField.text
            user?["cityState"] = "Portland, OR"
            user?["zipCode"] = requestZipField.text
            
            user?.saveInBackgroundWithBlock(nil)
        } else {
            saveAddressButton.setTitle("Remember Address", forState: .Normal)
            saveUserAddress = false
            user?.removeObjectForKey("streetAddress")
            user?.removeObjectForKey("cityState")
            user?.removeObjectForKey("zipCode")
            user?.saveInBackgroundWithBlock(nil)
        }
    }
    
// Segue Methods
    
    @IBAction func unwindToCreateRequestBController(segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ShowRequestPreview" {
            let invalidAddressFieldController = UIAlertController.invalidAddressAlertController()
            if requestAddressField.text == "" && locationPin == nil {
                self.presentViewController(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if requestZipField.text == "" && locationPin == nil {
                self.presentViewController(invalidAddressFieldController, animated: true, completion: nil)
                return false
            }
            if isZipValid(requestZipField.text!) == false && locationPin == nil {
                let invalidZipFieldController = UIAlertController.invalidZipAlertController()
                self.presentViewController(invalidZipFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        if segue.identifier == "ShowRequestPreview" {
            let preview = segue.destinationViewController as! CreateRequestCViewController
            let addressString = "\(requestAddressField.text) Portland, OR \(requestZipField.text) USA"
            let name = PFUser.currentUser()?.valueForKey("name") as! String
            preview.addressString = addressString
            preview.name = name
            preview.zipCode = requestZipField.text
            preview.homeAddress = requestAddressField.text
            preview.requestTitle = requestTitle
            preview.requestCategory = requestCategory
            preview.requestSwapType = requestSwapType
            preview.requestDescription = requestDescription
            preview.locationPin = locationPin
        }
        if segue.identifier == "AddPinToMap" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let pinOnMapController = navigationController.topViewController as! PutPinOnRequestMapViewController
            pinOnMapController.navigationController?.setNavigationBarHidden(false, animated: true)
            pinOnMapController.shouldRemoveLastPin = shouldRemoveLastPin
            if locationPin != nil && locationPin?.coordinate.latitude != 0.0 {
                pinOnMapController.lastPin = [locationPin!]
            } else {
                pinOnMapController.address = requestAddressField.text
                pinOnMapController.zip = requestZipField.text
            }
        }
    }
}
