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
            NSForegroundColorAttributeName: UIColor.white]
        // Setup views
         requestTitleTextField.layer.borderColor = UIColor.forestColor().cgColor
         requestTitleTextField.layer.borderWidth = 2
         requestTitleTextField.delegate = self
        requestDescriptionView.layer.borderColor = UIColor.forestColor().cgColor
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
            requestDescriptionView.font = UIFont.systemFont(ofSize: 17)
        }
        if self.view.frame.width == 320 {
            descriptionHeight.constant = 130
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with:event)
    }
    
    // Dismissing keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        requestTitleTextField.isUserInteractionEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        requestTitleTextField.isUserInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        requestDescriptionView.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        requestDescriptionView.isUserInteractionEnabled = true
    }
    
    @IBAction func saveDescription(_ sender: AnyObject) {
        delegate?.storeDescription(requestDescriptionView.text)
        delegate?.storeTitle(requestTitleTextField.text!)
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        requestObject["description"] = requestDescriptionView.text
        requestObject["title"] = requestTitleTextField.text
        
        requestObject.saveInBackground { (success, error) in
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
            let editRequestVC = segue.destination as! EditRequestViewController
            editRequestVC.requestDescription = requestDescriptionView.text
        }
    }
}
