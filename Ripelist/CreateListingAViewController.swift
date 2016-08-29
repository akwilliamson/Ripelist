//
//  CreateListingAViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import QuartzCore
import LKAlertController
import ActionSheetPicker_3_0
import ParseUI
import MapKit
import Flurry_iOS_SDK

class CreateListingAViewController: UIViewController,
                                    UITextFieldDelegate,
                                    UITextViewDelegate,
                                    CreateListingBViewControllerDelegate {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    let  goldColor = UIColor.goldColor()
    let  greyColor = UIColor.labelGreyColor()
    // Selection choices for picker views
    var amountTypeArray:[NSString] = []
      var categoryArray:[NSString] = []
      var swapTypeArray:[NSString] = []
    // ?
    let user = PFUser.currentUser()
    
// MARK: - Variables
    
    // Input Variables
    var previousPrice: Float = 0.00
    var previousButtonTitle = ""
    // Stores address and zip to prepopulate fields in CreateListingB
    var addressField: String?
    var zipField: String?
    // Stores location pin to prepopulate pin on map if it has been placed
    var locationPin: MKPointAnnotation?
    // Stores imageview to prepopulate pin on map if it has been placed
    var imageView: UIImageView?
    // Bools to check for validity of data
    var          forTrade = false
    var           forFree = false
    var listingTitleValid = false
    var     categoryValid = false
    var     swapTypeValid = false
    var        priceValid = false
    // Index path values used to prepopulate picker views with previous selections
    var previousChosenCategoryIndex: Int?
    var previousChosenSwapTypeIndex: Int?
    var     previousChosenUnitIndex: Int?
    // Pickerview variables
    var amountTypePickerView = UIPickerView(frame: CGRectMake(0, 15, 304, 0))
    var   categoryPickerView = UIPickerView(frame: CGRectMake(0, 15, 304, 0))
    var   swapTypePickerView = UIPickerView(frame: CGRectMake(0, 15, 304, 0))
    
// MARK: - Outlets
    
    // Views
    @IBOutlet weak var             dollarSign: UILabel!
    @IBOutlet weak var           listingTitle: UITextField!
    @IBOutlet weak var           listingPrice: UITextField!
    @IBOutlet weak var     listingDescription: UITextView!
    @IBOutlet weak var         categoryButton: UIButton!
    @IBOutlet weak var         swapTypeButton: UIButton!
    @IBOutlet weak var           amountButton: UIButton!
    @IBOutlet weak var             nextButton: UIButton!
    @IBOutlet weak var              arrowSign: UIImageView!
    // Constraints
    @IBOutlet weak var descriptionFieldBottom: NSLayoutConstraint!
    
// MARK: - View Construction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Create Listing A")
        let path = NSBundle.mainBundle().pathForResource("Categories", ofType:"plist")
        let dict = NSDictionary(contentsOfFile: path!)
        amountTypeArray = dict!["AmountType"] as! [NSString]
          categoryArray = dict!["CategoryType"] as! [NSString]
          swapTypeArray = dict!["ListingSwapType"] as! [NSString]
        
        // Hide empty black box on push
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // Set picker view widths depending on iOS device used
        if self.view.frame.width > 320 {
              categoryPickerView = UIPickerView(frame: CGRectMake(0, 15, 360, 0))
              swapTypePickerView = UIPickerView(frame: CGRectMake(0, 15, 360, 0))
            amountTypePickerView = UIPickerView(frame: CGRectMake(0, 15, 360, 0))
        }
        
        // For sliding view when keyboard is active or inactive
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(CreateListingAViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                       object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(CreateListingAViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                       object: nil)
        
        // Set outlet border and color styles
        SetupViews().setupSubViews([listingTitle, categoryButton, swapTypeButton, listingPrice, amountButton, listingDescription])
        listingDescription.text = "Enter a description (optional)"
        listingDescription.textColor = UIColor.lightGrayColor()
        listingDescription.layer.borderWidth = 2
        nextButton.backgroundColor = goldColor
        nextButton.layer.cornerRadius = 25
        
        // Initially hide outlets for price and unit type
          dollarSign.layer.hidden = true
        listingPrice.layer.hidden = true
           arrowSign.layer.hidden = true
        amountButton.layer.hidden = true
        
        // Conform outlets to proper delegates and data sources
              listingTitle.delegate = self
              listingPrice.delegate = self
        listingDescription.delegate = self
        
        // Add tags to picker views to display proper information when selected
        amountTypePickerView.tag = 1
          categoryPickerView.tag = 2
          swapTypePickerView.tag = 3
    }
    
    override func viewDidLayoutSubviews() {
        if self.view.frame.width > 325 {
            descriptionFieldBottom.constant = 30
        }
    }
    
// MARK: - NSNotification Methods
    
    // Slide view up when editing description
    func keyboardWillShow(sender: NSNotification) {
        if listingDescription.isFirstResponder() {
            if self.view.frame.width > 325 {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 72 }, completion: nil)
            } else {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 155 }, completion: nil)
            }
        }
        if listingPrice.isFirstResponder() || amountButton.isFirstResponder() {
            if self.view.frame.width == 320 {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y -= 55 }, completion: nil)
            }
        }
        
        if let keyboardSize = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.size {
            listingDescription.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            listingDescription.scrollIndicatorInsets = listingDescription.contentInset
        }
    }
    
    // Slide view down when finished editing description
    func keyboardWillHide(sender: NSNotification) {
        if listingDescription.isFirstResponder() {
            if self.view.frame.width > 325 {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 72}, completion: nil)
            } else {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 155 }, completion: nil)
            }
        }
        if listingPrice.isFirstResponder() || amountButton.isFirstResponder() {
            if self.view.frame.width == 320 {
                UIView.animateWithDuration(1.0, animations: { self.view.frame.origin.y += 55 }, completion: nil)
            }
        }
        
        listingDescription.contentInset = UIEdgeInsetsZero;
        listingDescription.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
// MARK: - Custom Delegate Methods
    
    func storeAddress(data: String?) {
        self.addressField = data
    }
    
    func storeZip(data: String?) {
        self.zipField = data
    }
    
    func storePin(data: MKPointAnnotation?) {
        self.locationPin = data
    }
    
    func storeImageView(data: UIImageView?) {
        self.imageView = data
    }
    
// MARK: - Textfield Delegate Methods
    
    // Dismissing keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
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
    
    // Should begin
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == listingPrice {
            listingDescription.resignFirstResponder()
        }
        return true
    }
    
    // Did begin
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == listingPrice {
            listingTitle.userInteractionEnabled = false
        }
        listingDescription.userInteractionEnabled = false
            categoryButton.userInteractionEnabled = false
            swapTypeButton.userInteractionEnabled = false
              amountButton.userInteractionEnabled = false
        textField.textColor = greenColor
    }
    
    // Did end
    func textFieldDidEndEditing(textField: UITextField) {
        listingDescription.userInteractionEnabled = true
            categoryButton.userInteractionEnabled = true
            swapTypeButton.userInteractionEnabled = true
              amountButton.userInteractionEnabled = true
        if textField == listingTitle {
            if listingTitle.text == "" {
                listingTitleValid = false
            } else {
                listingTitleValid = true
            }
        }
        // Sanitize price input
        if textField == listingPrice {
            listingTitle.userInteractionEnabled = true
            let listingPriceFloat = Float(listingPrice.text!)
            previousPrice = listingPriceFloat!
            listingPrice.text = NSString(format: "%.02f", listingPriceFloat!) as String
        }
        
        if listingPrice.text != "" && listingPrice.text != "0.00" && amountButton.currentTitle! != "Unit" {
            priceValid = true
        } else if listingPrice.layer.hidden == true {
            priceValid = true
        } else {
            priceValid = false
        }
        textField.textColor = greenColor
    }
    
// MARK: - Textview Delegate Methods
    
    // Did begin
    func textViewDidBeginEditing(textView: UITextView) {
        categoryButton.userInteractionEnabled = false
        swapTypeButton.userInteractionEnabled = false
          amountButton.userInteractionEnabled = false
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = greenColor
        }
    }
    
    // Did end
    func textViewDidEndEditing(textView: UITextView) {
        categoryButton.userInteractionEnabled = true
        swapTypeButton.userInteractionEnabled = true
          amountButton.userInteractionEnabled = true
        if textView.text.isEmpty {
            textView.text = "Enter a description (optional)"
            textView.textColor = UIColor.lightGrayColor()
        }
    }

// MARK: - Actions
    
    // Triggers category picker view selection
    @IBAction func chooseCategoryButton(sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingPrice.resignFirstResponder()
        
        let picker = ActionSheetStringPicker(title: "Category", rows: categoryArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.categoryArray[value] as String
                self.categoryButton.setTitleColor(self.greenColor, forState: .Normal)
                self.categoryButton.setTitle(title, forState: .Normal)
                self.categoryValid = true
            },
            cancelBlock: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker.setDoneButton(doneButton)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker.setCancelButton(cancelButton)
        
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.showActionSheetPicker()
    }
    
    // Triggers swap type picker view selection
    @IBAction func swapTypeButton(sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingPrice.resignFirstResponder()
        
        if listingPrice.text != "" && listingPrice.text != "0.00" && amountButton.currentTitle! != "unit" {
            priceValid = true
        } else if listingPrice.layer.hidden == true {
            priceValid = true
        } else {
            priceValid = false
        }
        
        let picker = ActionSheetStringPicker(title: "Swap Type", rows: swapTypeArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.swapTypeArray[value] as String
                self.swapTypeButton.setTitleColor(self.greenColor, forState: .Normal)
                self.swapTypeButton.setTitle(title, forState: .Normal)
                self.swapTypeValid = true

                switch value {
                case 0:
                    self.dollarSign.hidden = false
                    self.listingPrice.hidden = false
                    self.arrowSign.hidden = false
                    self.amountButton.hidden = false
                case 1:
                    self.forTrade = true
                    self.forFree = false
                    self.dollarSign.hidden = true
                    self.listingPrice.hidden = true
                    self.arrowSign.hidden = true
                    self.amountButton.hidden = true
                case 2:
                    self.forTrade = true
                    self.dollarSign.hidden = false
                    self.listingPrice.hidden = false
                    self.arrowSign.hidden = false
                    self.amountButton.hidden = false
                case 3:
                    self.forFree = true
                    self.forTrade = false
                    self.dollarSign.hidden = true
                    self.listingPrice.hidden = true
                    self.arrowSign.hidden = true
                    self.amountButton.hidden = true
                default:
                    return
                }
            },
            cancelBlock: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker.setDoneButton(doneButton)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker.setCancelButton(cancelButton)
        
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.showActionSheetPicker()
        
        // if chosen index includes for sale, display: dollarSign, listingPrice, arrowSign, and amountButton
    }
    
    // Triggers amount type picker view selection
    @IBAction func amountTypeButton(sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingDescription.resignFirstResponder()
        listingPrice.enabled = false
        listingPrice.enabled = true
        
        if listingPrice.text != "" && listingPrice.text != "0.00" {
            priceValid = true
        }
        if previousChosenUnitIndex == nil {
            self.amountButton.setTitle("N/A", forState: .Normal)
        } else {
            self.amountButton.setTitle(amountTypeArray[previousChosenUnitIndex!] as String, forState: .Normal)
        }
        
        let picker = ActionSheetStringPicker(title: "Unit Type", rows: amountTypeArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.amountTypeArray[value] as String
                self.amountButton.setTitle(title, forState: .Normal)
                self.amountButton.setTitleColor(self.greenColor, forState: .Normal)
            },
            cancelBlock: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker.setDoneButton(doneButton)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker.setCancelButton(cancelButton)
        
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker.showActionSheetPicker()
    }
    
// MARK: - Segue Methods
    
    // Validates required information
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        listingDescription.resignFirstResponder()
        let invalidFieldController = UIAlertController.invalidFieldAlertController()
        if identifier == "ShowMedia" {
            if !listingTitleValid || !categoryValid || !swapTypeValid || !priceValid {
                presentViewController(invalidFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        if segue.identifier == "ShowMedia" {
            let createListingBController = segue.destinationViewController as! CreateListingBViewController
            if listingDescription.text == "Enter a description (optional)" {
                createListingBController.listingDescription = "No description provided"
            } else {
                createListingBController.listingDescription = listingDescription.text
            }
            if addressField == nil {
                addressField = self.user?["streetAddress"] as! String?
            }
            if zipField == nil {
                zipField = self.user?["zipCode"] as! String?
            }
                         createListingBController.listingTitle = listingTitle.text
                      createListingBController.listingCategory = categoryButton.currentTitle
                         createListingBController.listingPrice = listingPrice.text
                        createListingBController.listingAmount = amountButton.currentTitle
                          createListingBController.locationPin = locationPin
                                createListingBController.image = imageView?.image
                              createListingBController.address = addressField
                                  createListingBController.zip = zipField
                             createListingBController.forTrade = forTrade
                              createListingBController.forFree = forFree
            createListingBController.addressFromCreateListingA = true
                             createListingBController.delegate = self
        }
    }
}
