
import ParseFacebookUtilsV4
import Flurry_iOS_SDK

enum OnboardType {
    case Login
    case SignUp
    case Reset
}

class OnboardVC: UIViewController {
    
    // Constraints
    @IBOutlet weak var errorBottom: NSLayoutConstraint!
    @IBOutlet weak var notifyY: NSLayoutConstraint!
    // UI
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: PadTextField!
    @IBOutlet weak var passwordTextField: PadTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var switchOnboardButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    var keyboardHeight: CGFloat!
    var offsetHeight: CGFloat!
    var onboardType: OnboardType = .Login
    
    lazy var pfInstallation: PFInstallation = {
        PFInstallation.currentInstallation()
    }()!
    
    lazy var nameTextField: PadTextField = {
        
        let frame = self.emailTextField.frame
        
        let rect: CGRect = CGRect(x: self.view.frame.width,
                                  y: frame.origin.y - (frame.height + 5),
                                  width: frame.width,
                                  height: frame.height)
        
        let nameTextField = PadTextField(frame: rect)
        nameTextField.placeholder = "Enter Your Name"
        nameTextField.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        nameTextField.backgroundColor = UIColor.whiteColor()
        nameTextField.alpha = 0.75
        
        return nameTextField
    }()
    
    let fbPermissions: [String] = [FBPermission.PublicProfile.rawValue, FBPermission.Email.rawValue]
    let fbParameters: [String: String] = ["fields": "id, name, first_name, last_name, email"]
    
// MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Login attempt")
        
        errorLabel.alpha = 0
        loginButton.userInteractionEnabled = false
        facebookLoginButton.adjustsImageWhenHighlighted = false
        
        addObservers(true)
        insertImages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        addObservers(false)
    }

// MARK: Actions
    
    @IBAction func backArrowTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onboardButtonTapped(sender: AnyObject) {
        
        switchOnboardButton.userInteractionEnabled = false
        resetPasswordButton.userInteractionEnabled = false
        
        guard let emailText = emailTextField.text,
                  passwordText = passwordTextField.text else { return }
        
        if !emailText.validEmail() {
            animateActivityIndicator(false)
            animateError(Error.InvalidEmail.string)
            return
        }
        
        animateActivityIndicator(true)
        
        switch onboardType {
        case .SignUp:
            
            guard let nameText = nameTextField.text else { return }
            
            if !nameText.validName() {
                animateActivityIndicator(false)
                animateError(Error.InvalidName.string)
                switchOnboardButton.userInteractionEnabled = true
                resetPasswordButton.userInteractionEnabled = false
                return
            } else if !passwordText.validPassword() {
                animateActivityIndicator(false)
                animateError(Error.PasswordLength.string)
                switchOnboardButton.userInteractionEnabled = true
                resetPasswordButton.userInteractionEnabled = false
                return
            }
            
            let user = PFUser()
            user["name"] = nameText
            user.username = nameText
            user.email = emailText
            user.password = passwordText
            
            user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if error != nil {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.NetworkError.string)
                    return
                } else {
                    
                    self.saveUser(user)
                    
                    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                    
                    self.view.endEditing(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        case .Login:
            
            PFUser.logInWithUsernameInBackground(emailText, password: passwordText) { (user: PFUser?, error: NSError?) in
                
                guard let user = user else {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.InvalidCredentials.string)
                    self.switchOnboardButton.userInteractionEnabled = true
                    self.resetPasswordButton.userInteractionEnabled = false
                    return
                }
                
                self.saveUser(user)
                
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        case .Reset:
            
            PFUser.requestPasswordResetForEmailInBackground(emailText, block: { (success: Bool, error: NSError?) -> Void in
                
                if error != nil {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.GeneralError.string)
                } else {
                    
                    self.animateActivityIndicator(false)
                    self.view.endEditing(true)
                    self.notifyLabel.text = "An email has been sent\nto reset your password"
                    self.notifyLabel.alpha = 0.75
                    
                    UIView.animateKeyframesWithDuration(3, delay: 0.5, options: [.CalculationModeLinear], animations: {
                        
                        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.02, animations: {
                            self.emailTextField.text = nil
                            self.notifyY.constant = 0
                            self.view.layoutIfNeeded()
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.02, relativeDuration: 0.98, animations: {
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.98, relativeDuration: 0.02, animations: {
                            self.notifyY.constant = -50
                            self.view.layoutIfNeeded()
                        })
                        }, completion: { _ in
                            self.notifyLabel.alpha = 0
                            self.switchOnboardButton.userInteractionEnabled = true
                            self.resetPasswordButton.userInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    @IBAction func resetPasswordTapped(sender: AnyObject) {
        
        switch onboardType {
            
        case .Login:
            
            emailTextField.fadePlaceholder(0.3, text: "Enter Your Email")
            
            UIView.animateWithDuration(0.3, animations: {
                self.passwordTextField.alpha = 0
                self.switchOnboardButton.alpha = 0
                self.facebookLoginButton.alpha = 0
                self.resetPasswordButton.setTitle("Cancel", forState: .Normal)
                self.loginButton.setTitle("Reset Password", forState: .Normal)
            }) { _ in
                self.passwordTextField.userInteractionEnabled = false
                self.switchOnboardButton.userInteractionEnabled = false
                self.facebookLoginButton.userInteractionEnabled = false
                self.onboardType = .Reset
            }
            
        case .Reset:
            
            emailTextField.fadePlaceholder(0.3, text: "Email")
            view.endEditing(true)
            
            UIView.animateWithDuration(0.3, animations: {
                self.passwordTextField.alpha = 0.75
                self.switchOnboardButton.alpha = 1
                self.facebookLoginButton.alpha = 1
                self.resetPasswordButton.setTitle("Reset Password", forState: .Normal)
                self.loginButton.setTitle("Login", forState: .Normal)
            }) { _ in
                self.passwordTextField.userInteractionEnabled = true
                self.switchOnboardButton.userInteractionEnabled = true
                self.facebookLoginButton.userInteractionEnabled = true
                self.onboardType = .Login
            }
            
        default:
            return
        }
    }
    
    @IBAction func switchOnboardTapped(sender: AnyObject) {
        
        errorLabel.alpha = 0
        
        if onboardType == .Login {
            
            emailTextField.fadePlaceholder(0.3, text: "Enter Your Email")
            passwordTextField.fadePlaceholder(0.3, text: "Create a Password")
            
            errorBottom.constant += emailTextField.frame.height
            view.setNeedsLayout()
            
            UIView.animateWithDuration(0.3, animations: {
                self.view.addSubview(self.nameTextField)
                self.nameTextField.frame.origin.x = self.emailTextField.frame.origin.x
                self.loginButton.setTitle("Sign Up", forState: .Normal)
                self.switchOnboardButton.setTitle("Login", forState: .Normal)
                self.resetPasswordButton.alpha = 0
                }, completion: { _ in
                    self.resetPasswordButton.userInteractionEnabled = false
                    self.onboardType = .SignUp
            })
            
        } else {
            
            emailTextField.fadePlaceholder(0.3, text: "Email")
            passwordTextField.fadePlaceholder(0.3, text: "Password")
            
            errorBottom.constant -= emailTextField.frame.height
            view.setNeedsLayout()
            
            UIView.animateWithDuration(0.3, animations: { 
                self.nameTextField.frame.origin.x = self.view.frame.width
                self.loginButton.setTitle("Login", forState: .Normal)
                self.switchOnboardButton.setTitle("Sign Up", forState: .Normal)
                self.resetPasswordButton.alpha = 1
                }, completion: { _ in
                    self.resetPasswordButton.userInteractionEnabled = true
                    self.nameTextField.removeFromSuperview()
                    self.onboardType = .Login
            })
        }
    }
    
    @IBAction func fbLoginButtonTapped(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermissions, block: { (user: PFUser?, error: NSError?) in
            
            guard let user = user else                      { return }
            if FBSDKAccessToken.currentAccessToken() == nil { return }
            
            FBSDKGraphRequest(graphPath: "me", parameters: self.fbParameters).startWithCompletionHandler { (connection, result, error) in
                
                if error != nil                                                            { return }
                guard let firstName = result?["first_name"], email = result?["email"] else { return }
                
                user["name"] = firstName
                user["email"] = email
                
                user.saveInBackgroundWithBlock(nil)
                self.saveUser(user)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
// MARK: Helpers
    
    private func saveUser(user: PFUser) {
        
        pfInstallation.addUniqueObject("ReloadMessages", forKey: "channels")
        pfInstallation["user"] = user
        pfInstallation.saveInBackgroundWithBlock(nil)
    }
    
    private func animateError(error: String) {
        
        self.errorLabel.text = error
        
        UIView.animateKeyframesWithDuration(2, delay: 0, options: [], animations: {

            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.025, animations: {
                if self.onboardType == .SignUp { self.nameTextField.frame.origin.y += 15 }
                self.emailTextField.frame.origin.y += 15
                self.passwordTextField.frame.origin.y += 15
                self.loginButton.frame.origin.y += 15
                self.resetPasswordButton.alpha = 0
                self.switchOnboardButton.alpha = 0
            })
            UIView.addKeyframeWithRelativeStartTime(0.025, relativeDuration: 0.05, animations: {
                self.errorLabel.alpha = 1
            })
            UIView.addKeyframeWithRelativeStartTime(0.925, relativeDuration: 0.075, animations: {
                self.errorLabel.alpha = 0
            })
            UIView.addKeyframeWithRelativeStartTime(0.975, relativeDuration: 0.025  , animations: {
                if self.onboardType == .SignUp { self.nameTextField.frame.origin.y -= 15 }
                self.emailTextField.frame.origin.y -= 15
                self.passwordTextField.frame.origin.y -= 15
                self.loginButton.frame.origin.y -= 15
                self.resetPasswordButton.alpha = 1
                self.switchOnboardButton.alpha = 1
            })
            }, completion: { _ in
                
        })
    }
    
    private func animateActivityIndicator(start: Bool) {
        
        start ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        let alpha: CGFloat = start ? 1 : 0
        
        UIView.animateWithDuration(0.2) {
            self.activityIndicator.alpha = alpha
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        guard let keyboardSize: CGSize = sender.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size,
              let offset: CGSize = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size else {
                
            return
        }
        
        keyboardHeight = keyboardSize.height
        offsetHeight = offset.height
        
        let height = keyboardHeight == offsetHeight && view.frame.origin.y == 0 ? -keyboardHeight / 2 : (keyboardHeight - offsetHeight) / 2
        
        UIView.animateWithDuration(0.2, animations: { _ in
            self.view.frame.origin.y += height
            self.logoLabel.alpha = 0
            self.facebookLoginButton.alpha = 0
        })
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        UIView.animateWithDuration(0.2, animations: { _ in
            self.view.frame.origin.y = 0
            self.logoLabel.alpha = 1
            self.errorLabel.alpha = 0
            if self.onboardType != .Reset {
                self.facebookLoginButton.alpha = 1
            }
        })
    }
    
    private func addObservers(add: Bool) {
        
        emailTextField.addTarget(self, action: .textFieldDidChange, forControlEvents: UIControlEvents.EditingChanged)
        passwordTextField.addTarget(self, action: .textFieldDidChange, forControlEvents: UIControlEvents.EditingChanged)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        if add {
            nc.addObserver(self, selector: .keyboardWillShow, name: UIKeyboardWillShowNotification, object: view.window)
            nc.addObserver(self, selector: .keyboardWillHide, name: UIKeyboardWillHideNotification, object: view.window)
        } else {
            nc.removeObserver(self, name: UIKeyboardWillShowNotification, object: view.window)
            nc.removeObserver(self, name: UIKeyboardWillHideNotification, object: view.window)
        }
    }
    
    func textFieldDidChange(sender: NSNotification) {
        
        switch onboardType {
        case .Reset:
            
            if emailTextField.text != "" {
                self.loginButton.userInteractionEnabled = true
                UIView.animateWithDuration(0.2, animations: {
                    self.loginButton.alpha = 1
                })
            }
        
        default:
            
            if emailTextField.text != "" && passwordTextField.text != "" {
                self.loginButton.userInteractionEnabled = true
                UIView.animateWithDuration(0.2, animations: {
                    self.loginButton.alpha = 1
                })
            } else {
                self.loginButton.userInteractionEnabled = false
                UIView.animateWithDuration(0.2, animations: {
                    self.loginButton.alpha = 0.75
                })
            }
            
        }
    }
    
    private func insertImages() {
        
        if let bgLoginImage = UIImage(named: "bg_login") {
            insertImage(bgLoginImage, view: view)
        } else {
            view.backgroundColor = UIColor.forestColor()
        }

    }
    
    private func insertImage(image: UIImage, view: UIView) {
        
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        
        view.insertSubview(imageView, atIndex: 0)
    }
}

extension OnboardVC: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
