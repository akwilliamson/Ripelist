//
//  CreateRequestAViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ParseUI
import MapKit
import Flurry_iOS_SDK

class CreateRequestAViewController: UIViewController,
                                    UITextFieldDelegate,
                                    UITextViewDelegate,
                                    CreateRequestBViewControllerDelegate {
    
// MARK: - Constants
    
    // Colors
    let greenColor = UIColor.forestColor()
    // ?
    var categoryArray:[NSString] = []
    var swapTypeArray:[NSString] = []
    // ?
    let user = PFUser.current()
    
// MARK: - Variables
    
    // ?
    var categoryPickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 304, height: 0))
    var swapTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 304, height: 0))
    var titleValid = false
    var categoryValid = false
    var swapTypeValid = false
    // ?
    var previousChosenCategoryIndex: Int?
    var previousChosenSwapTypeIndex: Int?
    // ?
    var locationPin: MKPointAnnotation?
    var addressField: String?
    var zipField: String?

// MARK: - Outlets
    
    @IBOutlet weak var             titleLabel: TextField!
    @IBOutlet weak var    descriptionTextView: UITextView!
    @IBOutlet weak var         categoryButton: UIButton!
    @IBOutlet weak var         swapTypeButton: UIButton!
    @IBOutlet weak var             nextButton: UIButton!
    // Constraints
    @IBOutlet weak var descriptionFieldBottom: NSLayoutConstraint!
    
// MARK: - View Construction    
    
    override func viewDidLoad() {
        Flurry.logEvent("Create Request A")
        self.navigationController?.setToolbarHidden(true, animated: false) // Hide empty black box on push
        
        let path = Bundle.main.path(forResource: "Categories", ofType:"plist")
        let dict = NSDictionary(contentsOfFile: path!)
        categoryArray = dict!["CategoryType"] as! [NSString]
        swapTypeArray = dict!["RequestSwapType"] as! [NSString]
        
        // Set picker view width depending on iOS device used
        if self.view.frame.width > 320 {
            categoryPickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 360, height: 0))
            swapTypePickerView = UIPickerView(frame: CGRect(x: 0, y: 15, width: 360, height: 0))
        }

        // For sliding view up when keyboard is displayed
        NotificationCenter.default.addObserver(self, selector: #selector(CreateRequestAViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(CreateRequestAViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        // Setting initial border and color values
        
        SetupViews().setupSubViews([titleLabel, categoryButton, swapTypeButton, descriptionTextView])
        swapTypeButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 25
        descriptionTextView.text = "Enter a description (optional)"
        descriptionTextView.textColor = UIColor.lightGray
        
        // Assigning proper delegates/data sources/tags
        titleLabel.delegate = self
        swapTypePickerView.tag = 1
        categoryPickerView.tag = 2
        descriptionTextView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if self.view.frame.width > 325 {
            descriptionFieldBottom.constant = 30
        }
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
    
// MARK: - Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with:event)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        if descriptionTextView.isFirstResponder {
            if self.view.frame.width > 325 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 72 }, completion: nil)
            } else {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y -= 155 }, completion: nil)
            }
        }
    }
    func keyboardWillHide(_ sender: Notification) {
        if descriptionTextView.isFirstResponder {
            if self.view.frame.width > 325 {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 72}, completion: nil)
            } else {
                UIView.animate(withDuration: 1.0, animations: { self.view.frame.origin.y += 155 }, completion: nil)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        descriptionTextView.isUserInteractionEnabled = false
             categoryButton.isUserInteractionEnabled = false
             swapTypeButton.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        descriptionTextView.isUserInteractionEnabled = true
             categoryButton.isUserInteractionEnabled = true
             swapTypeButton.isUserInteractionEnabled = true
        if textField.text != "" {
            titleValid = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        swapTypeButton.isUserInteractionEnabled = true
        if textView.text.isEmpty {
            textView.text = "Enter a description (optional)"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        swapTypeButton.isUserInteractionEnabled = false
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = greenColor
        }
    }
    
    @IBAction func categoryButton(_ sender: AnyObject) {
        titleLabel.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
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
    @IBAction func swapTypeButton(_ sender: AnyObject) {
        titleLabel.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        let picker = ActionSheetStringPicker(title: "Swap Type", rows: swapTypeArray, initialSelection: 0,
            doneBlock: { (picker, value, index) -> Void in
                let title = self.swapTypeArray[value] as String
                self.swapTypeButton.setTitleColor(self.greenColor, for: UIControlState())
                self.swapTypeButton.setTitle(title, for: UIControlState())
                self.swapTypeValid = true
            },
            cancel: { action in
                
            }, origin: self.view)
        
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
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        self.view.endEditing(true)
        let invalidFieldController = UIAlertController.invalidFieldAlertController()
        if identifier == "ShowLocation" {
            if !titleValid || !categoryValid || !swapTypeValid {
                present(invalidFieldController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        if segue.identifier == "ShowLocation" {
            let createRequestBController = segue.destination as! CreateRequestBViewController
            createRequestBController.requestTitle = titleLabel.text
            createRequestBController.requestCategory = categoryButton.currentTitle
            createRequestBController.requestSwapType = swapTypeButton.currentTitle
            if descriptionTextView.text == "Enter a description (optional)" {
                createRequestBController.requestDescription = "No description provided"
            } else {
                createRequestBController.requestDescription = descriptionTextView.text
            }
            if addressField == nil {
                addressField = self.user?["streetAddress"] as! String?
            }
            if zipField == nil {
                zipField = self.user?["zipCode"] as! String?
            }
            createRequestBController.address = addressField
            createRequestBController.zip = zipField
            createRequestBController.locationPin = locationPin
            createRequestBController.addressFromCreateRequestA = true
            createRequestBController.delegate = self
        }
    }
}



//        swapTypePickerView.delegate = self
//        swapTypePickerView.dataSource = self
//        categoryPickerView.delegate = self
//        categoryPickerView.dataSource = self
//
//    // 1 component for each
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    // Number of rows = number of array values for each
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
//        return pickerView.tag == 1 ? swapTypeArray.count : categoryArray.count
//    }
//
//    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 70.0
//    }
//
//    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
//
//        if pickerView.tag == 1 {
//            let label = UILabel(frame: CGRectMake(-15, 5, 130, 60))
//            label.font = UIFont(name: "ArialRoundedMTBold", size: 20)
//            label.textColor = UIColor.forestColor()
//            label.textAlignment = .Center
//            label.backgroundColor = UIColor.clearColor()
//            label.text = swapTypeArray[row] as String
//            let view = UIView(frame: CGRectMake(0, 0, 100, 70))
//            view.insertSubview(label, atIndex: 1)
//
//            return view
//
//        } else {
//            let image = UIImage(named: "category\(row).png")
//            let iconView = UIImageView(image: image)
//            iconView.frame = CGRectMake(-50, 10, 50, 50)
//
//            let label = UILabel(frame: CGRectMake(50, 5, 100, 60))
//            label.font = UIFont(name: "ArialRoundedMTBold", size: 21)
//            label.textColor = UIColor.forestColor()
//            label.textAlignment = .Left
//            label.backgroundColor = UIColor.clearColor()
//            label.text = categoryArray[row] as String
//            let view = UIView(frame: CGRectMake(0, 0, 100, 70))
//            view.insertSubview(iconView, atIndex: 0)
//            view.insertSubview(label, atIndex: 1)
//
//            return view
//
//        }
//    }

// Set button's text to the selected row in the picker view
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView.tag == 1 {
//            swapTypeButton.setTitle(swapTypeArray[row] as String, forState: .Normal)
//            previousChosenSwapTypeIndex = row
//        } else {
//            categoryButton.setTitle(categoryArray[row] as String, forState: .Normal)
//            previousChosenCategoryIndex = row
//        }
//    }

