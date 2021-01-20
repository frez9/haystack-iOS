//
//  LoginViewController.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
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
            let displayName = me["displayName"] as? String
            let external_Id = me["externalId"] as? String
            let bitmoji = me["bitmoji"] as? [String: Any]
            let avatar = bitmoji?["avatar"] as? String
            
            if avatar == nil {
                self.defaults.set("nil", forKey: "avatar_url")
            } else {
                self.defaults.set(avatar, forKey: "avatar_url")
            }
            
            if displayName == nil {
                self.defaults.set("nil", forKey: "display_name")
            } else {
                self.defaults.set(displayName, forKey: "display_name")
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
        
//        if self.defaults.bool(forKey: "did_accept_eula") == false {
//            print("-----------------------------------------------------")
//            let alert = UIAlertController(title: "Terms of Use", message: "By using Haystack you agree to the terms of service (EULA) and privacy policy. Haystack has no tolerance for objectionable content or abusive users. You'll be banned for any inappropriate usage.", preferredStyle: .alert)
//            
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Accept terms"), style: .default, handler: { _ in
//                self.defaults.set(true, forKey: "did_accept_eula")
//                self.getUserInfo()
//                self.defaults.set(true, forKey: "user_did_login")
//            }))
//        
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Leave", comment: "Decline Terms of Use"), style: .destructive, handler: { _ in
//                
//                self.dismiss(animated: true, completion: nil)
//            }))
//        
//            self.present(alert, animated: true, completion: nil)
//        }

        loginButton = SCSDKLoginButton() { (success: Bool, error: Error?) in
            if success {
                if self.defaults.bool(forKey: "did_accept_eula") == false {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "EULA & Terms of Service", message: "By using Haystack you agree to the terms of service (EULA) and privacy policy. Haystack has no tolerance for objectionable content or abusive users.", preferredStyle: .alert)
            
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "Accept terms"), style: .default, handler: { _ in
                            
                            self.defaults.set(true, forKey: "did_accept_eula")
                            self.getUserInfo()
                            self.defaults.set(true, forKey: "user_did_login")
                        }))
            
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Decline", comment: "Decline Terms of Use"), style: .destructive, handler: { _ in
            
                            self.dismiss(animated: true, completion: nil)
                        }))
            
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.getUserInfo()
                    self.defaults.set(true, forKey: "user_did_login")
                }
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
