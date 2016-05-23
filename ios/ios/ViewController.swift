//
//  ViewController.swift
//  ios
//
//  Created by Aristote Diasonama on 16-05-21.
//  Copyright © 2016 Aristote Diasonama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var introMessage: UIStackView!
    @IBOutlet weak var afterLoginMessage: UILabel!
   
    
    let loginButton : FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile","email", "user_actions.music"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpViews()
        
        if let _ = FBSDKAccessToken.currentAccessToken() {
            fetchProfile()
        }
    }
    
    func setUpViews() {
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self
        
        
        userImage.layer.borderWidth=1.0
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.whiteColor().CGColor
        userImage.layer.cornerRadius = userImage.frame.size.width/2
        userImage.clipsToBounds = true
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        fetchProfile()
    }
    
    func fetchProfile() {
        let parameters = ["fields": "first_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            
            if requestError != nil {
                print(requestError)
                return
            }
            
            self.loginButton.hidden = true
            self.introMessage.hidden = true
            
            self.userImage.hidden = false
            self.afterLoginMessage.hidden = false
            
            let firstName = user["first_name"] as? String
            
            self.afterLoginMessage.text = "\(firstName!), patientes pendant que nous trouvons les activités qui vont te plaire ..."
            
            var pictureUrl = ""
            
            if let picture = user["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                pictureUrl = url
            }
            
            let url = NSURL(string: pictureUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error)
                    return
                }
                
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.userImage.image = image
                })
                
            }).resume()
            
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}

