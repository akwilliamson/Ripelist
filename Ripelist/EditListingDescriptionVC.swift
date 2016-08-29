//
//  EditDescriptionViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 6/5/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit
import ParseUI
import Flurry_iOS_SDK

class EditListingDescriptionViewController: UIViewController,
                                            UITextViewDelegate,
                                            UITextFieldDelegate {

    var listingDescription: String?
    var listingTitle: String!
    var listingObject: PFObject!
    var listingCannotBeRetrieved = false
    var delegate: StoreListingEditsDelegate?
    
    @IBOutlet weak var listingTitleTextField: TextField!
    @IBOutlet weak var listingDescriptionView: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Edit Listing Description")
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 25)!,
                                                                        NSForegroundColorAttributeName: UIColor.whiteColor()]
        // Setup views
        listingTitleTextField.layer.borderColor = UIColor.forestColor().CGColor
        listingTitleTextField.layer.borderWidth = 2
        listingTitleTextField.delegate = self
        listingDescriptionView.layer.borderColor = UIColor.forestColor().CGColor
        listingDescriptionView.layer.borderWidth = 2
        listingDescriptionView.textColor = UIColor.forestColor()
        listingDescriptionView.delegate = self
        saveButton.layer.cornerRadius = 25
        // Setup content
        listingTitleTextField.text = listingTitle
        if let description = listingDescription {
            listingDescriptionView.text = description
        }
        // Setup layout
        if self.view.frame.width > 320 {
            listingDescriptionView.font = UIFont.systemFontOfSize(17)
        }
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 130
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        listingTitleTextField.userInteractionEnabled = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        listingTitleTextField.userInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        listingDescriptionView.userInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        listingDescriptionView.userInteractionEnabled = true
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
    
    @IBAction func saveDescription(sender: AnyObject) {
        delegate?.storeDescription(listingDescriptionView.text)
        delegate?.storeTitle(listingTitleTextField.text!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.transform = CGAffineTransformMakeScale(2, 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        listingObject["description"] = listingDescriptionView.text
        listingObject["title"] = listingTitleTextField.text
        listingObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
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
            let editListingVC = segue.destinationViewController as! EditListingViewController
            editListingVC.listingDescription = listingDescriptionView.text
        }
    }
}
