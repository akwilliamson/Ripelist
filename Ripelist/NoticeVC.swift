//
//  ViewController.swift
//  Ripelist
//
//  Created by Aaron Williamson on 2/25/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {
    
    var petitionAlert: UIAlertController!
    
    @IBOutlet weak var petitionButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLaunchedOnce")
        createAlert()
    }
    
    @IBAction func liveSomewhereElseTapped(sender: AnyObject) {
        self.presentViewController(petitionAlert, animated: true, completion: nil)
    }
    
    func createAlert() {
        petitionAlert = UIAlertController(title: "Petition", message: "Sign up to bring Ripelist to your city!", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { _ in
            if let cityText = (self.petitionAlert.textFields?[1])?.text, emailText = (self.petitionAlert.textFields?[2])?.text {
                let nameText = self.petitionAlert.textFields?[0].text
                self.postMailChimpPetitioner(nameText, inCity: cityText, withEmail: emailText)
                self.performSegueWithIdentifier("ShowHome", sender: self)
            }
        }
        submitAction.enabled = false
    
        petitionAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Name (optional)"
        }
        
        petitionAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Your City"
        }
        
        petitionAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Email"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { _ in
                submitAction.enabled = textField.text != ""
            }
        }
        
        petitionAlert.addAction(cancelAction)
        petitionAlert.addAction(submitAction)
    }
    
    func postMailChimpPetitioner(name: String?, inCity city: String, withEmail email: String) {
        let mailChimpAPI = MailChimpAPI()
        mailChimpAPI.createRequest(name, city: city, email: email)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! HomeViewController
        
        destinationVC.tabBar.selectionIndicatorImage = UIImage(named: "gold-background.png")
    }
}







