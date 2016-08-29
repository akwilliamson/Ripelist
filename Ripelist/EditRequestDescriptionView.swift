//
//  EditDescriptionViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/18/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import ParseUI
import UIKit
import Flurry_iOS_SDK

class EditRequestDescriptionViewController: UIViewController,
                                            UITextViewDelegate,
                                            UITextFieldDelegate {
    
    var requestDescription: String?
    var requestTitle: String!
    var requestObject: PFObject!
    var requestCannotBeRetrieved = false
    var delegate: StoreRequestEditsDelegate?
    
    @IBOutlet weak var requestTitleTextField: TextField!
    @IBOutlet weak var requestDescriptionView: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Request Description")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        // Setup views
         requestTitleTextField.layer.borderColor = UIColor.forestColor().CGColor
         requestTitleTextField.layer.borderWidth = 2
         requestTitleTextField.delegate = self
        requestDescriptionView.layer.borderColor = UIColor.forestColor().CGColor
        requestDescriptionView.layer.borderWidth = 2
        requestDescriptionView.textColor = UIColor.forestColor()
        requestDescriptionView.delegate = self
        saveButton.layer.cornerRadius = 25
        // Setup content
        requestTitleTextField.text = requestTitle
        if let description = requestDescription {
            requestDescriptionView.text = description
        }
        // Setup layout
        if self.view.frame.width > 320 {
            requestDescriptionView.font = UIFont.systemFontOfSize(17)
        }
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 130
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    // Dismissing keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let line = textView.caretRectForPosition((textView.selectedTextRange?.start)!) as CGRect
        let overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top) as CGFloat
        if overflow > 0 {
            var offset = textView.contentOffset as CGPoint
            offset.y += overflow + 7
            UIView.animateWithDuration(0.2, animations: {textView.setContentOffset(offset, animated: true)})
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        requestTitleTextField.userInteractionEnabled = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        requestTitleTextField.userInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        requestDescriptionView.userInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        requestDescriptionView.userInteractionEnabled = true
    }
    
    @IBAction func saveDescription(sender: AnyObject) {
        delegate?.storeDescription(requestDescriptionView.text)
        delegate?.storeTitle(requestTitleTextField.text!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.transform = CGAffineTransformMakeScale(2, 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        requestObject["description"] = requestDescriptionView.text
        requestObject["title"] = requestTitleTextField.text
        requestObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                activityView.stopAnimating()
                self.performSegueWithIdentifier("UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UnwindToEditListing" {
            let editRequestVC = segue.destinationViewController as! EditRequestViewController
            editRequestVC.requestDescription = requestDescriptionView.text
        }
    }
}