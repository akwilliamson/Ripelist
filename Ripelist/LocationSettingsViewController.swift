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
    let user = PFUser.current()
    
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
        
        savedAddressField.layer.borderColor = greenColor.cgColor
        savedZipField.layer.borderColor = greenColor.cgColor
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocationSettingsViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationSettingsViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , with:event)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        if self.view.frame.width < 325 {
            if savedZipField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 155 }, completion: nil)
            }
        }
    }
    func keyboardWillHide(_ sender: Notification) {
        if self.view.frame.width < 325 {
            if savedZipField.isFirstResponder {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 155 }, completion: nil)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == savedAddressField {
            savedZipField.isUserInteractionEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == savedAddressField {
            savedZipField.isUserInteractionEnabled = true
        }
    }
    
    
    
    @IBAction func updateAddress(_ sender: AnyObject) {
        self.addressHasBeenUpdatedCheckmark.isHidden = true
        user?["streetAddress"] = savedAddressField.text
        user?.saveInBackground { (success: Bool, error: NSError?) -> Void in
            if success == true {
                self.addressHasBeenUpdatedCheckmark.isHidden = false
            }
        }
    }
    
    @IBAction func updateZipCode(_ sender: AnyObject) {
        self.zipCodeHasBeenUpdatedCheckmark.isHidden = true
        user?["zipCode"] = savedZipField.text
        user?.saveInBackground { (success: Bool, error: NSError?) -> Void in
            if success == true {
                self.zipCodeHasBeenUpdatedCheckmark.isHidden = false
            }
        }
    }
    
    @IBAction func deleteZipAndAddress(_ sender: AnyObject) {
        user?.remove(forKey: "streetAddress")
        user?.remove(forKey: "zipCode")
        user?.saveInBackground {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                self.savedAddressField.text = nil
                self.savedZipField.text = nil
                self.addressHasBeenUpdatedCheckmark.isHidden = true
                self.zipCodeHasBeenUpdatedCheckmark.isHidden = true
            }
        }
    }
}
