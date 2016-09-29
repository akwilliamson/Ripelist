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
        UserDefaults.standard.set(true, forKey: "hasLaunchedOnce")
        createAlert()
    }
    
    @IBAction func liveSomewhereElseTapped(_ sender: AnyObject) {
        self.present(petitionAlert, animated: true, completion: nil)
    }
    
    func createAlert() {
        petitionAlert = UIAlertController(title: "Petition", message: "Sign up to bring Ripelist to your city!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            if let cityText = (self.petitionAlert.textFields?[1])?.text, let emailText = (self.petitionAlert.textFields?[2])?.text {
                let nameText = self.petitionAlert.textFields?[0].text
                self.postMailChimpPetitioner(nameText, inCity: cityText, withEmail: emailText)
                self.performSegue(withIdentifier: "ShowHome", sender: self)
            }
        }
        submitAction.isEnabled = false
    
        petitionAlert.addTextField { textField in
            textField.placeholder = "Name (optional)"
        }
        
        petitionAlert.addTextField { textField in
            textField.placeholder = "Your City"
        }
        
        petitionAlert.addTextField { textField in
            textField.placeholder = "Email"
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                submitAction.isEnabled = textField.text != ""
            }
        }
        
        petitionAlert.addAction(cancelAction)
        petitionAlert.addAction(submitAction)
    }
    
    func postMailChimpPetitioner(_ name: String?, inCity city: String, withEmail email: String) {
        let mailChimpAPI = MailChimpAPI()
        mailChimpAPI.createRequest(name, city: city, email: email)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HomeViewController
        
        destinationVC.tabBar.selectionIndicatorImage = UIImage(named: "gold-background.png")
    }
}







