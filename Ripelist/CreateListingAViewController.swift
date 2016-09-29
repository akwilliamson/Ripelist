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
    let user = PFUser.current()
    
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
    var amountTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 304, height: 0))
    var   categoryPickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 304, height: 0))
    var   swapTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 304, height: 0))
    
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
        let path = Bundle.main.path(forResource: "Categories", ofType:"plist")
        let dict = NSDictionary(contentsOfFile: path!)
        amountTypeArray = dict!["AmountType"] as! [NSString]
          categoryArray = dict!["CategoryType"] as! [NSString]
          swapTypeArray = dict!["ListingSwapType"] as! [NSString]
        
        // Hide empty black box on push
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // Set picker view widths depending on iOS device used
        if self.view.frame.width > 320 {
              categoryPickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 360, height: 0))
              swapTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 360, height: 0))
            amountTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 360, height: 0))
        }
        
        // For sliding view when keyboard is active or inactive
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(CreateListingAViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                       object: nil)
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(CreateListingAViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                       object: nil)
        
        // Set outlet border and color styles
        SetupViews().setupSubViews([listingTitle, categoryButton, swapTypeButton, listingPrice, amountButton, listingDescription])
        listingDescription.text = "Enter a description (optional)"
        listingDescription.textColor = UIColor.lightGray
        listingDescription.layer.borderWidth = 2
        nextButton.backgroundColor = goldColor
        nextButton.layer.cornerRadius = 25
        
        // Initially hide outlets for price and unit type
          dollarSign.layer.isHidden = true
        listingPrice.layer.isHidden = true
           arrowSign.layer.isHidden = true
        amountButton.layer.isHidden = true
        
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
    func keyboardWillShow(_ sender: Notification) {
        if listingDescription.isFirstResponder {
            if self.view.frame.width > 325 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 72 }, completion: nil)
            } else {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 155 }, completion: nil)
            }
        }
        if listingPrice.isFirstResponder || amountButton.isFirstResponder {
            if self.view.frame.width == 320 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 55 }, completion: nil)
            }
        }
        
        if let keyboardSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).size {
            listingDescription.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            listingDescription.scrollIndicatorInsets = listingDescription.contentInset
        }
    }
    
    // Slide view down when finished editing description
    func keyboardWillHide(_ sender: Notification) {
        if listingDescription.isFirstResponder {
            if self.view.frame.width > 325 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 72}, completion: nil)
            } else {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 155 }, completion: nil)
            }
        }
        if listingPrice.isFirstResponder || amountButton.isFirstResponder {
            if self.view.frame.width == 320 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 55 }, completion: nil)
            }
        }
        
        listingDescription.contentInset = UIEdgeInsets.zero;
        listingDescription.scrollIndicatorInsets = UIEdgeInsets.zero;
    }
    
// MARK: - Custom Delegate Methods
    
    func storeAddress(_ data: String?) {
        self.addressField = data
    }
    
    func storeZip(_ data: String?) {
        self.zipField = data
    }
    
    func storePin(_ data: MKPointAnnotation?) {
        self.locationPin = data
    }
    
    func storeImageView(_ data: UIImageView?) {
        self.imageView = data
    }
    
// MARK: - Textfield Delegate Methods
    
    // Dismissing keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , with:event)
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
    
    // Should begin
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == listingPrice {
            listingDescription.resignFirstResponder()
        }
        return true
    }
    
    // Did begin
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == listingPrice {
            listingTitle.isUserInteractionEnabled = false
        }
        listingDescription.isUserInteractionEnabled = false
            categoryButton.isUserInteractionEnabled = false
            swapTypeButton.isUserInteractionEnabled = false
              amountButton.isUserInteractionEnabled = false
        textField.textColor = greenColor
    }
    
    // Did end
    func textFieldDidEndEditing(_ textField: UITextField) {
        listingDescription.isUserInteractionEnabled = true
            categoryButton.isUserInteractionEnabled = true
            swapTypeButton.isUserInteractionEnabled = true
              amountButton.isUserInteractionEnabled = true
        if textField == listingTitle {
            if listingTitle.text == "" {
                listingTitleValid = false
            } else {
                listingTitleValid = true
            }
        }
        // Sanitize price input
        if textField == listingPrice {
            listingTitle.isUserInteractionEnabled = true
            let listingPriceFloat = Float(listingPrice.text!)
            previousPrice = listingPriceFloat!
            listingPrice.text = NSString(format: "%.02f", listingPriceFloat!) as String
        }
        
        if listingPrice.text != "" && listingPrice.text != "0.00" && amountButton.currentTitle! != "Unit" {
            priceValid = true
        } else if listingPrice.layer.isHidden == true {
            priceValid = true
        } else {
            priceValid = false
        }
        textField.textColor = greenColor
    }
    
// MARK: - Textview Delegate Methods
    
    // Did begin
    func textViewDidBeginEditing(_ textView: UITextView) {
        categoryButton.isUserInteractionEnabled = false
        swapTypeButton.isUserInteractionEnabled = false
          amountButton.isUserInteractionEnabled = false
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = greenColor
        }
    }
    
    // Did end
    func textViewDidEndEditing(_ textView: UITextView) {
        categoryButton.isUserInteractionEnabled = true
        swapTypeButton.isUserInteractionEnabled = true
          amountButton.isUserInteractionEnabled = true
        if textView.text.isEmpty {
            textView.text = "Enter a description (optional)"
            textView.textColor = UIColor.lightGray
        }
    }

// MARK: - Actions
    
    // Triggers category picker view selection
    @IBAction func chooseCategoryButton(_ sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingPrice.resignFirstResponder()
        
        let picker = ActionSheetStringPicker(title: "Category", rows: categoryArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.categoryArray[value] as String
                self.categoryButton.setTitleColor(self.greenColor, for: UIControlState())
                self.categoryButton.setTitle(title, for: UIControlState())
                self.categoryValid = true
            },
            cancel: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker?.setDoneButton(doneButton)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker?.setCancelButton(cancelButton)
        
        picker?.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.show()
    }
    
    // Triggers swap type picker view selection
    @IBAction func swapTypeButton(_ sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingPrice.resignFirstResponder()
        
        if listingPrice.text != "" && listingPrice.text != "0.00" && amountButton.currentTitle! != "unit" {
            priceValid = true
        } else if listingPrice.layer.isHidden == true {
            priceValid = true
        } else {
            priceValid = false
        }
        
        let picker = ActionSheetStringPicker(title: "Swap Type", rows: swapTypeArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.swapTypeArray[value] as String
                self.swapTypeButton.setTitleColor(self.greenColor, for: UIControlState())
                self.swapTypeButton.setTitle(title, for: UIControlState())
                self.swapTypeValid = true

                switch value {
                case 0:
                    self.dollarSign.isHidden = false
                    self.listingPrice.isHidden = false
                    self.arrowSign.isHidden = false
                    self.amountButton.isHidden = false
                case 1:
                    self.forTrade = true
                    self.forFree = false
                    self.dollarSign.isHidden = true
                    self.listingPrice.isHidden = true
                    self.arrowSign.isHidden = true
                    self.amountButton.isHidden = true
                case 2:
                    self.forTrade = true
                    self.dollarSign.isHidden = false
                    self.listingPrice.isHidden = false
                    self.arrowSign.isHidden = false
                    self.amountButton.isHidden = false
                case 3:
                    self.forFree = true
                    self.forTrade = false
                    self.dollarSign.isHidden = true
                    self.listingPrice.isHidden = true
                    self.arrowSign.isHidden = true
                    self.amountButton.isHidden = true
                default:
                    return
                }
            },
            cancel: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker?.setDoneButton(doneButton)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker?.setCancelButton(cancelButton)
        
        picker?.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.show()
        
        // if chosen index includes for sale, display: dollarSign, listingPrice, arrowSign, and amountButton
    }
    
    // Triggers amount type picker view selection
    @IBAction func amountTypeButton(_ sender: UIButton) {
        listingTitle.resignFirstResponder()
        listingDescription.resignFirstResponder()
        listingPrice.isEnabled = false
        listingPrice.isEnabled = true
        
        if listingPrice.text != "" && listingPrice.text != "0.00" {
            priceValid = true
        }
        if previousChosenUnitIndex == nil {
            self.amountButton.setTitle("N/A", for: UIControlState())
        } else {
            self.amountButton.setTitle(amountTypeArray[previousChosenUnitIndex!] as String, for: UIControlState())
        }
        
        let picker = ActionSheetStringPicker(title: "Unit Type", rows: amountTypeArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.amountTypeArray[value] as String
                self.amountButton.setTitle(title, for: UIControlState())
                self.amountButton.setTitleColor(self.greenColor, for: UIControlState())
            },
            cancel: { action in }, origin: self.view)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        doneButton.tintColor = greenColor
        picker?.setDoneButton(doneButton)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        cancelButton.tintColor = greenColor
        picker?.setCancelButton(cancelButton)
        
        picker?.pickerTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!, NSForegroundColorAttributeName: greenColor]
        picker?.show()
    }
    
// MARK: - Segue Methods
    
    // Validates required information
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        listingDescription.resignFirstResponder()
        let invalidFieldController = UIAlertController.invalidFieldAlertController()
        if identifier == "ShowMedia" {
            if !listingTitleValid || !categoryValid || !swapTypeValid || !priceValid {
                present(invalidFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        if segue.identifier == "ShowMedia" {
            let createListingBController = segue.destination as! CreateListingBViewController
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
                                createListingBController.image = (imageView?.image)!
                              createListingBController.address = addressField
                                  createListingBController.zip = zipField
                             createListingBController.forTrade = forTrade
                              createListingBController.forFree = forFree
            createListingBController.addressFromCreateListingA = true
                             createListingBController.delegate = self
        }
    }
}
