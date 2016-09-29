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
                                                                        NSForegroundColorAttributeName: UIColor.white]
        // Setup views
        listingTitleTextField.layer.borderColor = UIColor.forestColor().cgColor
        listingTitleTextField.layer.borderWidth = 2
        listingTitleTextField.delegate = self
        listingDescriptionView.layer.borderColor = UIColor.forestColor().cgColor
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
            listingDescriptionView.font = UIFont.systemFont(ofSize: 17)
        }
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 130
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches , with:event)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        listingTitleTextField.isUserInteractionEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        listingTitleTextField.isUserInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        listingDescriptionView.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        listingDescriptionView.isUserInteractionEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let line = textView.caretRect(for: (textView.selectedTextRange?.start)!) as CGRect
        let overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top) as CGFloat
        if overflow > 0 {
            var offset = textView.contentOffset as CGPoint
            offset.y += overflow + 7
            UIView.animate(withDuration: 0.2, animations: {textView.setContentOffset(offset, animated: true)})
        }
    }
    
    @IBAction func saveDescription(_ sender: AnyObject) {
        delegate?.storeDescription(listingDescriptionView.text)
        delegate?.storeTitle(listingTitleTextField.text!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        listingObject["description"] = listingDescriptionView.text
        listingObject["title"] = listingTitleTextField.text
        listingObject.saveInBackground { (success, error) in
            if success {
                activityView.stopAnimating()
                self.performSegue(withIdentifier: "UnwindToEditListing", sender: self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToEditListing" {
            let editListingVC = segue.destination as! EditListingViewController
            editListingVC.listingDescription = listingDescriptionView.text
        }
    }
}
