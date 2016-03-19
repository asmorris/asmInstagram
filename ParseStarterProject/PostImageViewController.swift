//
//  PostImageViewController.swift
//  asmInstagram
//
//  Created by Andrew Morrison on 2016-03-18.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func chooseImageButton(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
    }
    
    
    @IBAction func postImageButton(sender: AnyObject) {
        
        if imageToPost.image == nil || messageTextField.text == "" {
            
            displayAlert("Uh oh!", message: "Looks like you forgot a message and/or image to upload!")
        
        } else {

            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post = PFObject(className: "Post")
            post["message"] = messageTextField.text
            post["userId"] = PFUser.currentUser()?.objectId
            
            let imageData = UIImageJPEGRepresentation(imageToPost.image!, 1.0)
            
            let imageFile = PFFile(name: "image.png", data: imageData!)
            
            post["imageFile"] = imageFile
            
            post.saveInBackgroundWithBlock { (success, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    self.imageToPost.image = UIImage(named: "Unknown.jpeg")
                    self.displayAlert("Awesome!", message: "You got it")
                } else {
                    self.displayAlert("Something's gone wonky", message: "Shit's fucked yo")
                }
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    //MARK: Display alert
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

}
