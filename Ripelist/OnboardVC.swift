
import ParseFacebookUtilsV4
import Flurry_iOS_SDK

enum OnboardType {
    case login
    case signUp
    case reset
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
    var onboardType: OnboardType = .login
    
    lazy var pfInstallation: PFInstallation = {
        PFInstallation.current()
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
        nameTextField.backgroundColor = UIColor.white
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
        loginButton.isUserInteractionEnabled = false
        facebookLoginButton.adjustsImageWhenHighlighted = false
        
        addObservers(true)
        insertImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        addObservers(false)
    }

// MARK: Actions
    
    @IBAction func backArrowTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onboardButtonTapped(_ sender: AnyObject) {
        
        switchOnboardButton.isUserInteractionEnabled = false
        resetPasswordButton.isUserInteractionEnabled = false
        
        guard let emailText = emailTextField.text,
                  let passwordText = passwordTextField.text else { return }
        
        if !emailText.validEmail() {
            animateActivityIndicator(false)
            animateError(Error.invalidEmail.string)
            return
        }
        
        animateActivityIndicator(true)
        
        switch onboardType {
        case .signUp:
            
            guard let nameText = nameTextField.text else { return }
            
            if !nameText.validName() {
                animateActivityIndicator(false)
                animateError(Error.invalidName.string)
                switchOnboardButton.isUserInteractionEnabled = true
                resetPasswordButton.isUserInteractionEnabled = false
                return
            } else if !passwordText.validPassword() {
                animateActivityIndicator(false)
                animateError(Error.passwordLength.string)
                switchOnboardButton.isUserInteractionEnabled = true
                resetPasswordButton.isUserInteractionEnabled = false
                return
            }
            
            let user = PFUser()
            user["name"] = nameText
            user.username = nameText
            user.email = emailText
            user.password = passwordText
            
            user.signUpInBackground { (success: Bool, error: NSError?) -> Void in
                if error != nil {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.networkError.string)
                    return
                } else {
                    
                    self.saveUser(user)
                    
                    let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .login:
            
            PFUser.logInWithUsername(inBackground: emailText, password: passwordText) { (user: PFUser?, error: NSError?) in
                
                guard let user = user else {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.invalidCredentials.string)
                    self.switchOnboardButton.isUserInteractionEnabled = true
                    self.resetPasswordButton.isUserInteractionEnabled = false
                    return
                }
                
                self.saveUser(user)
                
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
        case .reset:
            
            PFUser.requestPasswordResetForEmail(inBackground: emailText, block: { (success: Bool, error: NSError?) -> Void in
                
                if error != nil {
                    self.animateActivityIndicator(false)
                    self.animateError(Error.generalError.string)
                } else {
                    
                    self.animateActivityIndicator(false)
                    self.view.endEditing(true)
                    self.notifyLabel.text = "An email has been sent\nto reset your password"
                    self.notifyLabel.alpha = 0.75
                    
                    UIView.animateKeyframes(withDuration: 3, delay: 0.5, options: UIViewKeyframeAnimationOptions(), animations: {
                        
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.02, animations: {
                            self.emailTextField.text = nil
                            self.notifyY.constant = 0
                            self.view.layoutIfNeeded()
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.02, relativeDuration: 0.98, animations: {
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.98, relativeDuration: 0.02, animations: {
                            self.notifyY.constant = -50
                            self.view.layoutIfNeeded()
                        })
                        }, completion: { _ in
                            self.notifyLabel.alpha = 0
                            self.switchOnboardButton.isUserInteractionEnabled = true
                            self.resetPasswordButton.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    @IBAction func resetPasswordTapped(_ sender: AnyObject) {
        
        switch onboardType {
            
        case .login:
            
            emailTextField.fadePlaceholder(0.3, text: "Enter Your Email")
            
            UIView.animate(withDuration: 0.3, animations: {
                self.passwordTextField.alpha = 0
                self.switchOnboardButton.alpha = 0
                self.facebookLoginButton.alpha = 0
                self.resetPasswordButton.setTitle("Cancel", for: UIControlState())
                self.loginButton.setTitle("Reset Password", for: UIControlState())
            }, completion: { _ in
                self.passwordTextField.isUserInteractionEnabled = false
                self.switchOnboardButton.isUserInteractionEnabled = false
                self.facebookLoginButton.isUserInteractionEnabled = false
                self.onboardType = .reset
            }) 
            
        case .reset:
            
            emailTextField.fadePlaceholder(0.3, text: "Email")
            view.endEditing(true)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.passwordTextField.alpha = 0.75
                self.switchOnboardButton.alpha = 1
                self.facebookLoginButton.alpha = 1
                self.resetPasswordButton.setTitle("Reset Password", for: UIControlState())
                self.loginButton.setTitle("Login", for: UIControlState())
            }, completion: { _ in
                self.passwordTextField.isUserInteractionEnabled = true
                self.switchOnboardButton.isUserInteractionEnabled = true
                self.facebookLoginButton.isUserInteractionEnabled = true
                self.onboardType = .login
            }) 
            
        default:
            return
        }
    }
    
    @IBAction func switchOnboardTapped(_ sender: AnyObject) {
        
        errorLabel.alpha = 0
        
        if onboardType == .login {
            
            emailTextField.fadePlaceholder(0.3, text: "Enter Your Email")
            passwordTextField.fadePlaceholder(0.3, text: "Create a Password")
            
            errorBottom.constant += emailTextField.frame.height
            view.setNeedsLayout()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.addSubview(self.nameTextField)
                self.nameTextField.frame.origin.x = self.emailTextField.frame.origin.x
                self.loginButton.setTitle("Sign Up", for: UIControlState())
                self.switchOnboardButton.setTitle("Login", for: UIControlState())
                self.resetPasswordButton.alpha = 0
                }, completion: { _ in
                    self.resetPasswordButton.isUserInteractionEnabled = false
                    self.onboardType = .signUp
            })
            
        } else {
            
            emailTextField.fadePlaceholder(0.3, text: "Email")
            passwordTextField.fadePlaceholder(0.3, text: "Password")
            
            errorBottom.constant -= emailTextField.frame.height
            view.setNeedsLayout()
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.nameTextField.frame.origin.x = self.view.frame.width
                self.loginButton.setTitle("Login", for: UIControlState())
                self.switchOnboardButton.setTitle("Sign Up", for: UIControlState())
                self.resetPasswordButton.alpha = 1
                }, completion: { _ in
                    self.resetPasswordButton.isUserInteractionEnabled = true
                    self.nameTextField.removeFromSuperview()
                    self.onboardType = .login
            })
        }
    }
    
    @IBAction func fbLoginButtonTapped(_ sender: AnyObject) {
        PFFacebookUtils.logInInBackground(withReadPermissions: fbPermissions, block: { (user: PFUser?, error: NSError?) in
            
            guard let user = user else                      { return }
            if FBSDKAccessToken.current() == nil { return }
            
            FBSDKGraphRequest(graphPath: "me", parameters: self.fbParameters).start { (connection, result, error) in
                
                if error != nil                                                            { return }
                guard let firstName = result?["first_name"], let email = result?["email"] else { return }
                
                user["name"] = firstName
                user["email"] = email
                
                user.saveInBackground(block: nil)
                self.saveUser(user)
                
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
// MARK: Helpers
    
    fileprivate func saveUser(_ user: PFUser) {
        
        pfInstallation.addUniqueObject("ReloadMessages", forKey: "channels")
        pfInstallation["user"] = user
        pfInstallation.saveInBackground(block: nil)
    }
    
    fileprivate func animateError(_ error: String) {
        
        self.errorLabel.text = error
        
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [], animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.025, animations: {
                if self.onboardType == .signUp { self.nameTextField.frame.origin.y += 15 }
                self.emailTextField.frame.origin.y += 15
                self.passwordTextField.frame.origin.y += 15
                self.loginButton.frame.origin.y += 15
                self.resetPasswordButton.alpha = 0
                self.switchOnboardButton.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.025, relativeDuration: 0.05, animations: {
                self.errorLabel.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0.925, relativeDuration: 0.075, animations: {
                self.errorLabel.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.975, relativeDuration: 0.025  , animations: {
                if self.onboardType == .signUp { self.nameTextField.frame.origin.y -= 15 }
                self.emailTextField.frame.origin.y -= 15
                self.passwordTextField.frame.origin.y -= 15
                self.loginButton.frame.origin.y -= 15
                self.resetPasswordButton.alpha = 1
                self.switchOnboardButton.alpha = 1
            })
            }, completion: { _ in
                
        })
    }
    
    fileprivate func animateActivityIndicator(_ start: Bool) {
        
        start ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        let alpha: CGFloat = start ? 1 : 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = alpha
        }) 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        
        guard let keyboardSize: CGSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size,
              let offset: CGSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size else {
                
            return
        }
        
        keyboardHeight = keyboardSize.height
        offsetHeight = offset.height
        
        let height = keyboardHeight == offsetHeight && view.frame.origin.y == 0 ? -keyboardHeight / 2 : (keyboardHeight - offsetHeight) / 2
        
        UIView.animate(withDuration: 0.2, animations: { _ in
            self.view.frame.origin.y += height
            self.logoLabel.alpha = 0
            self.facebookLoginButton.alpha = 0
        })
    }
    
    func keyboardWillHide(_ sender: Notification) {
        
        UIView.animate(withDuration: 0.2, animations: { _ in
            self.view.frame.origin.y = 0
            self.logoLabel.alpha = 1
            self.errorLabel.alpha = 0
            if self.onboardType != .reset {
                self.facebookLoginButton.alpha = 1
            }
        })
    }
    
    fileprivate func addObservers(_ add: Bool) {
        
        emailTextField.addTarget(self, action: .textFieldDidChange, for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: .textFieldDidChange, for: UIControlEvents.editingChanged)
        
        let nc = NotificationCenter.default
        
        if add {
            nc.addObserver(self, selector: .keyboardWillShow, name: NSNotification.Name.UIKeyboardWillShow, object: view.window)
            nc.addObserver(self, selector: .keyboardWillHide, name: NSNotification.Name.UIKeyboardWillHide, object: view.window)
        } else {
            nc.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: view.window)
            nc.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: view.window)
        }
    }
    
    func textFieldDidChange(_ sender: Notification) {
        
        switch onboardType {
        case .reset:
            
            if emailTextField.text != "" {
                self.loginButton.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.loginButton.alpha = 1
                })
            }
        
        default:
            
            if emailTextField.text != "" && passwordTextField.text != "" {
                self.loginButton.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.loginButton.alpha = 1
                })
            } else {
                self.loginButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.loginButton.alpha = 0.75
                })
            }
            
        }
    }
    
    fileprivate func insertImages() {
        
        if let bgLoginImage = UIImage(named: "bg_login") {
            insertImage(bgLoginImage, view: view)
        } else {
            view.backgroundColor = UIColor.forestColor()
        }

    }
    
    fileprivate func insertImage(_ image: UIImage, view: UIView) {
        
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        
        view.insertSubview(imageView, at: 0)
    }
}

extension OnboardVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
