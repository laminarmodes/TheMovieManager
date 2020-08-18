//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        //performSegue(withIdentifier: "completeLogin", sender: nil)
        // 7. instead of segwaying
        setLogginIn(true)
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        //performSegue(withIdentifier: "completeLogin", sender: nil)
    // implement each login step
        // Step 1:
        setLogginIn(true)
        TMDBClient.getRequestToken { (success, error) in
            if success {
                
               // DispatchQueue.main.async {
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
              //  }
                
                // app hands off the request for validating the request token to the broswer
            }
        }
    
    }
    
    // 6.  Create a function to handle the response
    func handleRequestTokenResponse(success: Bool, error: Error?)
    {
        if success {
            print(TMDBClient.Auth.requestToken)
          //  DispatchQueue.main.async {
                TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
         //   }
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?)
    {
        setLogginIn(false)
        print(TMDBClient.Auth.requestToken)
        if success
        {
            TMDBClient.createSessionId(completion: handleSessionResponse(success:error:))
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?)
    {
        if success
        {
           // DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
           // }
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLogginIn(_ loggingIn: Bool)
    {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaWebsiteButton.isEnabled = !loggingIn
    }
    
    // Error step 4. Alert the user in the UI
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}
