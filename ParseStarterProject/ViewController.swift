/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    var signUpActive = true
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainButtonLabel: UIButton!
    @IBOutlet weak var secondaryButtonLabel: UIButton!
    @IBOutlet weak var registeredTextLabel: UILabel!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
 
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser()?.objectId != nil {

            self.performSegueWithIdentifier("login", sender: self)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, message: String) {
        if #available(iOS 8.0, *) {
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: { (action) -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert("Error in form", message: "Please enter a username and password")
            
        } else {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"

            
            if signUpActive == true {
                var user = PFUser()
                user.username = usernameTextField.text
                user.password = passwordTextField.text
                
                
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        //Signup successful
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed sign up", message: errorMessage)
                    }
                    
                })
            } else {
                PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if user != nil {
                        //Logged in!
                        
                        self.performSegueWithIdentifier("login", sender: self)

                    } else {
                        if let errorString = error?.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed log in", message: errorMessage)

                    }
                })
            }
            
        }
        
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        
        if signUpActive == true {
            mainButtonLabel.setTitle("Log In", forState: UIControlState.Normal)
            registeredTextLabel.text = "Not Registered?"
            secondaryButtonLabel.setTitle("Sign Up", forState: UIControlState.Normal)
            signUpActive = false
        } else {
            mainButtonLabel.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredTextLabel.text = "Already Registered?"
            secondaryButtonLabel.setTitle("Log In", forState: UIControlState.Normal)
            signUpActive = true

        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
