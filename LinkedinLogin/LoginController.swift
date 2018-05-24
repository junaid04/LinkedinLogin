//
//  ViewController.swift
//  LinkedinLogin
//
//  Created by AJK on 10/17/16.
//  Copyright © 2016 ajk. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    let loadingView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        contentView.isHidden = true
        btnLogin.setTitleColor(UIColor.blue, for: UIControlState())
        loadingView.activityIndicatorViewStyle = .whiteLarge
        loadingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        loadingView.color = UIColor.black
        self.view.addSubview(loadingView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkForToken()
        
    }
    
    @IBAction func loginTap(_ sender: AnyObject) {
        
        if btnLogin.tag == 0 {
            
            self.performSegue(withIdentifier: "Login", sender: self)
            
        }
            
        else {
            
            UserDefaults.standard.removeObject(forKey: "AccessToken")
            btnLogin.setTitle("Login", for: UIControlState())
            btnLogin.setTitleColor(UIColor.blue, for: UIControlState())
            btnLogin.tag = 0
            contentView.isHidden = true
            
        }
        
    }
    
    func checkForToken() {
        
        if let accessToken = UserDefaults.standard.object(forKey: "AccessToken") {
            // Specify the URL string that we'll get the profile info from.
            
            btnLogin.setTitle("", for: UIControlState())
            btnLogin.tag = 1
            loadingView.startAnimating()
            
            let targetURLString = "https://api.linkedin.com/v1/people/~:(id,email-address,first-name,last-name,formatted-name,picture-url)?format=json"
            
            
            // Initialize a mutable URL request object.
            var request = URLRequest(url: URL(string: targetURLString)!)
            
            // Indicate that this is a GET request.
            request.httpMethod = "GET"
            
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            // Initialize a NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                
                if error == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    
                    if statusCode == 200 {
                        // Convert the received JSON data into a dictionary.
                        do {
                            let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                            print(dataDictionary)
                            
                            let firstName = dataDictionary["firstName"] as! String
                            let lastName = dataDictionary["lastName"] as! String
                            let fullName = dataDictionary["formattedName"] as! String
                            let email = dataDictionary["emailAddress"] as! String
                            let picture = dataDictionary["pictureUrl"] as! String
                            let pictureUrl = URL(string: picture)!
                            
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                self.btnLogin.setTitle("Logout", for: UIControlState())
                                self.btnLogin.setTitleColor(UIColor.red, for: UIControlState())
                                self.loadingView.stopAnimating()
                                self.contentView.isHidden = false
                                self.lblFirstName.text = firstName
                                self.lblLastName.text = lastName
                                self.lblFullName.text = fullName
                                self.lblEmail.text = email
                                if let data = try? Data(contentsOf: pictureUrl) {
                                    
                                    self.imageView.image = UIImage(data: data)
                                }
                                
                            })
                        }
                        catch {
                            print("Could not convert JSON data into a dictionary.")
                        }
                    }
                }
                    
                else {
                    self.loadingView.stopAnimating()
                    print(error!.localizedDescription)
                }
            })
            
            //self.loadingView.stopAnimating()
            task.resume()
        }
    }
}
