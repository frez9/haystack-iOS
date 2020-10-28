//
//  ProfileViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 9/12/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import UIKit
import SafariServices
import SCSDKLoginKit
import Firebase

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var profileTableView: UITableView!
    
    var firstCell: UITableViewCell = UITableViewCell()
    var myListingsCell: UITableViewCell = UITableViewCell()
    var myFavoritesCell: UITableViewCell = UITableViewCell()
    var freePickupCell: UITableViewCell = UITableViewCell()
    var freeSuppliesCell: UITableViewCell = UITableViewCell()
    var snapUsernameCell: UITableViewCell = UITableViewCell()
    var privacyPolicyCell: UITableViewCell = UITableViewCell()
    var helpCell: UITableViewCell = UITableViewCell()
    var logoutCell: UITableViewCell = UITableViewCell()
    
    var usernameView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var usernameField: UITextField!
    var doneButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Profile"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop"), style: .plain, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePop))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        profileTableView = UITableView()
        profileTableView.separatorInset = .zero
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.isScrollEnabled = false
        profileTableView.alwaysBounceVertical = false
        profileTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileTableView)
        
        firstCell.isUserInteractionEnabled = false
        firstCell.backgroundColor = .white
        firstCell.selectionStyle = .none
        
        myListingsCell.textLabel?.text = "My Listings"
        myListingsCell.backgroundColor = .white
        myListingsCell.accessoryType = .disclosureIndicator
        myListingsCell.selectionStyle = .none
        myListingsCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        myFavoritesCell.textLabel?.text = "My Favorites"
        myFavoritesCell.backgroundColor = .white
        myFavoritesCell.accessoryType = .disclosureIndicator
        myFavoritesCell.selectionStyle = .none
        myFavoritesCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        freeSuppliesCell.textLabel?.text = "Free Shipping Supplies"
        freeSuppliesCell.backgroundColor = .white
        freeSuppliesCell.accessoryType = .disclosureIndicator
        freeSuppliesCell.selectionStyle = .none
        freeSuppliesCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        freePickupCell.textLabel?.text = "Free Package Pickup"
        freePickupCell.backgroundColor = .white
        freePickupCell.accessoryType = .disclosureIndicator
        freePickupCell.selectionStyle = .none
        freePickupCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        snapUsernameCell.textLabel?.text = "Snapchat Username"
        snapUsernameCell.backgroundColor = .white
        snapUsernameCell.selectionStyle = .none
        snapUsernameCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        privacyPolicyCell.textLabel?.text = "Privacy Policy"
        privacyPolicyCell.backgroundColor = .white
        privacyPolicyCell.accessoryType = .disclosureIndicator
        privacyPolicyCell.selectionStyle = .none
        privacyPolicyCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        helpCell.textLabel?.text = "Help"
        helpCell.backgroundColor = .white
        helpCell.selectionStyle = .none
        helpCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)

        logoutCell.textLabel?.text = "Logout"
        logoutCell.textLabel?.textColor = .red
        logoutCell.backgroundColor = .white
        logoutCell.selectionStyle = .none
        logoutCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        usernameView = UIView()
        usernameView.alpha = 0
        usernameView.backgroundColor = .white
        usernameView.layer.borderWidth = 0.5
        usernameView.layer.cornerRadius = 20
        usernameView.frame.size.height = 185
        usernameView.frame.size.width = 275
        usernameView.center = view.center
        view.addSubview(usernameView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 17)
        titleLabel.text = "Enter Your Snapchat Username"
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.init(name: "AvenirNext-Medium", size: 15)
        subtitleLabel.text = "(this is how buyers will reach you)"
        subtitleLabel.textColor = .black
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(subtitleLabel)
        
        usernameField = UITextField()
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        let atLabel = UILabel()
        atLabel.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        atLabel.text = "@ "
        atLabel.textColor = .black
        usernameField.leftView = atLabel
        usernameField.leftViewMode = .always
        usernameField.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(usernameField)
        
        doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 17)
        doneButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        doneButton.layer.cornerRadius = 15
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(doneButton)
    
        
        setUpConstraints()

    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor), profileTableView.topAnchor.constraint(equalTo: view.topAnchor), profileTableView.bottomAnchor.constraint(equalTo: profileTableView.topAnchor, constant: 550)])
        
        NSLayoutConstraint.activate([titleLabel.centerXAnchor.constraint(equalTo: usernameView.centerXAnchor), titleLabel.topAnchor.constraint(equalTo: usernameView.topAnchor, constant: 15)])
        
        NSLayoutConstraint.activate([subtitleLabel.centerXAnchor.constraint(equalTo: usernameView.centerXAnchor), subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)])
        
        NSLayoutConstraint.activate([usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20), usernameField.leadingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: -60), usernameField.trailingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: 60)])
        
        NSLayoutConstraint.activate([doneButton.leadingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: -65), doneButton.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: -35), doneButton.bottomAnchor.constraint(equalTo: usernameView.bottomAnchor, constant: -15), doneButton.trailingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: 65)])
    
    }
    
    @objc func handlePop(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            break
            
        case .ended:
            viewTranslation = sender.translation(in: view)
            if viewTranslation.x > 0 {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
            
        default:
            break
        }
        
    }
    
    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneButtonTapped() {
        UIView.animate(withDuration: 0.15, animations: {
            self.usernameView.alpha = 0
            self.usernameView.endEditing(true)
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.myListingsCell.isUserInteractionEnabled = true
            self.myFavoritesCell.isUserInteractionEnabled = true
            self.freeSuppliesCell.isUserInteractionEnabled = true
            self.freePickupCell.isUserInteractionEnabled = true
            self.snapUsernameCell.isUserInteractionEnabled = true
            self.privacyPolicyCell.isUserInteractionEnabled = true
            self.helpCell.isUserInteractionEnabled = true
            self.logoutCell.isUserInteractionEnabled = true
        })
        if usernameField.text != defaults.string(forKey: "snapchat_username") {
            defaults.set(usernameField.text, forKey: "snapchat_username")
            NetworkManager.updateSnapchatUsername()
        }
        if defaults.bool(forKey: "did_show_username_view") == false {
            defaults.set(true, forKey: "did_show_username_view")
        }
    }

}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                return
            case 1:
                Analytics.logEvent("my_listings_cell_pressed", parameters: nil)
                let vc = UserProductsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                Analytics.logEvent("my_favorites_cell_pressed", parameters: nil)
                let vc = UserFavoritesViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                Analytics.logEvent("shipping_supplies_cell_pressed", parameters: nil)
                let urlString = "https://store.usps.com/store/results/boxes/shipping-supplies-free-shipping-supplies/red/_/N-yz4qdpZ17iopsjZjwhhik"

                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self

                    present(vc, animated: true)
                }
            case 4:
                Analytics.logEvent("package_pickup_cell_pressed", parameters: nil)
                let urlString = "https://tools.usps.com/schedule-pickup-steps.htm"

                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self

                    present(vc, animated: true)
                }
            case 5:
                Analytics.logEvent("snapchat_username_cell_pressed", parameters: nil)
                usernameField.text = defaults.string(forKey: "snapchat_username")
                usernameView.alpha = 1
                navigationController?.navigationBar.isUserInteractionEnabled = false
                myListingsCell.isUserInteractionEnabled = false
                myFavoritesCell.isUserInteractionEnabled = false
                freeSuppliesCell.isUserInteractionEnabled = false
                freePickupCell.isUserInteractionEnabled = false
                snapUsernameCell.isUserInteractionEnabled = false
                privacyPolicyCell.isUserInteractionEnabled = false
                helpCell.isUserInteractionEnabled = false
                logoutCell.isUserInteractionEnabled = false
                
            case 6:
                Analytics.logEvent("privacy_policy_cell_pressed", parameters: nil)
                let urlString = "https://docs.google.com/document/d/1FTkYHmByldZtJGYnu9ZQQv73-qzeUkGMVTGjYWawtVY/edit?usp=sharing"

                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self

                    present(vc, animated: true)
                }
            case 7:
                Analytics.logEvent("help_cell_pressed", parameters: nil)
                UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/haystack_app")!)
            case 8:
                let alert = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Don't logout"), style: .default, handler: { _ in
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout"), style: .destructive, handler: { _ in
                    Analytics.logEvent("final_logout_button_pressed", parameters: nil)
                    SCSDKLoginClient.clearToken()
                    let vc = LoginViewController()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: vc)
                }))
                
                self.present(alert, animated: true, completion: nil)
            default: fatalError("Unknown row in section 0")
            }
        default: fatalError("Unknown section")
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0: return firstCell
            case 1: return myListingsCell
            case 2: return myFavoritesCell
            case 3: return freeSuppliesCell
            case 4: return freePickupCell
            case 5: return snapUsernameCell
            case 6: return privacyPolicyCell
            case 7: return helpCell
            case 8: return logoutCell
            default: fatalError("Unknown row in section 0")
            }
        default: fatalError("Unknown section")
        
        }

    }
    
}
