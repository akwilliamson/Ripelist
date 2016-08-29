//
//  LocationSettingsViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/22/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import QuartzCore
import ParseUI
import Flurry_iOS_SDK

class LocationSettingsViewController: UIViewController,
                                      UITextFieldDelegate {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    let user = PFUser.currentUser()
    
// MARK: - Outlets

    @IBOutlet weak var              savedAddressField: TextField!
    @IBOutlet weak var                  savedZipField: TextField!
    @IBOutlet weak var addressHasBeenUpdatedCheckmark: UILabel!
    @IBOutlet weak var zipCodeHasBeenUpdatedCheckmark: UILabel!
    @IBOutlet weak var            updateAddressButton: UIButton!
    @IBOutlet weak var                updateZipButton: UIButton!
    @IBOutlet weak var           removeLocationButton: UIButton!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Location Settings")
        self.title = "Location"
        
        // Hide empty black box on push
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        savedAddressField.layer.borderColor = greenColor.CGColor
        savedZipField.layer.borderColor = greenColor.CGColor
        
        savedAddressField.layer.borderWidth = 2
        savedZipField.layer.borderWidth = 2
        
        savedAddressField.delegate = self
        savedZipField.delegate = self
        
        updateAddressButton.layer.cornerRadius = 25
        updateZipButton.layer.cornerRadius = 25
        removeLocationButton.layer.cornerRadius = 25
        
        let address = self.user?["streetAddress"] as! String?
        let zipCode = self.user?["zipCode"] as! String?

        self.savedAddressField.text = address
        self.savedZipField.text = zipCode
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationSettingsViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationSettingsViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if self.view.frame.width < 325 {
            if savedZipField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 155 }, completion: nil)
            }
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.width < 325 {
            if savedZipField.isFirstResponder() {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 155 }, completion: nil)
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == savedAddressField {
            savedZipField.userInteractionEnabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == savedAddressField {
            savedZipField.userInteractionEnabled = true
        }
    }
    
    
    
    @IBAction func updateAddress(sender: AnyObject) {
        self.addressHasBeenUpdatedCheckmark.hidden = true
        user?["streetAddress"] = savedAddressField.text
        user?.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success == true {
                self.addressHasBeenUpdatedCheckmark.hidden = false
            }
        }
    }
    
    @IBAction func updateZipCode(sender: AnyObject) {
        self.zipCodeHasBeenUpdatedCheckmark.hidden = true
        user?["zipCode"] = savedZipField.text
        user?.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success == true {
                self.zipCodeHasBeenUpdatedCheckmark.hidden = false
            }
        }
    }
    
    @IBAction func deleteZipAndAddress(sender: AnyObject) {
        user?.removeObjectForKey("streetAddress")
        user?.removeObjectForKey("zipCode")
        user?.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                self.savedAddressField.text = nil
                self.savedZipField.text = nil
                self.addressHasBeenUpdatedCheckmark.hidden = true
                self.zipCodeHasBeenUpdatedCheckmark.hidden = true
            }
        }
    }
}
