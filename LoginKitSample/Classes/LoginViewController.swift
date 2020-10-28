//
//  LoginViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 8/27/20.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit
import SCSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var loginButton: SCSDKLoginButton!
    var iconView: UIImageView!
    var appNameLabel: UILabel!
    
    let defaults = UserDefaults.standard

}

extension LoginViewController {
    
    func getUserInfo() {
        let successBlock = { (response: [AnyHashable: Any]?) in
            guard let response = response as? [String: Any],
                let data = response["data"] as? [String: Any],
                let me = data["me"] as? [String: Any] else {
                    return
            }
            
            let external_Id = me["externalId"] as? String
            let bitmoji = me["bitmoji"] as? [String: Any]
            let avatar = bitmoji?["avatar"] as? String
            
            if avatar == nil {
                self.defaults.set("nil", forKey: "avatar_url")
            } else {
                self.defaults.set(avatar, forKey: "avatar_url")
            }

            self.defaults.set(external_Id, forKey: "external_id")

            
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([HomeViewController()], animated: false)
                if self.defaults.bool(forKey: "created_user_in_db") == false {
                    NetworkManager.createUser()
                    self.defaults.set(true, forKey: "created_user_in_db")
                }
            }
        }
        
        let failureBlock = { (error: Error?, success: Bool) in
            if let error = error {
                print(String.init(format: "Failed to fetch user data. Details: %@", error.localizedDescription))
            }
        }
        
        let queryString = "{me{externalId, displayName, bitmoji{avatar}}}"

        SCSDKLoginClient.fetchUserData(withQuery: queryString,
                                       variables: nil,
                                       success: successBlock,
                                       failure: failureBlock)
    }
}

extension LoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        iconView = UIImageView()
        let iconImage = UIImage(named: "launchicon")
        iconView.contentMode = .scaleToFill
        iconView.frame.size.width = 93
        iconView.frame.size.height = 93
        iconView.image = iconImage
        iconView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconView)
        
        appNameLabel = UILabel()
        appNameLabel.frame.size.width = 111
        appNameLabel.frame.size.height = 33
        appNameLabel.text = "Haystack"
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.init(name: "AvenirNext-Bold", size: 25)
        appNameLabel.textAlignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appNameLabel)
        

        loginButton = SCSDKLoginButton() { (success: Bool, error: Error?) in
            if success {
                self.getUserInfo()
            }
            if (error != nil) {
                DispatchQueue.main.async {
                }
            }
        }
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([loginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: -50), loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40), loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -130), loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 130)])
        
        NSLayoutConstraint.activate([appNameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), appNameLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
    
        NSLayoutConstraint.activate([iconView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), iconView.bottomAnchor.constraint(equalTo: appNameLabel.topAnchor)])

    }

}

