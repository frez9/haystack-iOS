//
//  ProductViewController.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
//

import UIKit
import Firebase
import BraintreeDropIn
import Braintree

var productId: Int! = 0

class ProductViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var delegate: FavoriteProtocol?
    
    var id: Int!
    var favorited: Bool!
    
    var productImage: UIImageView! = UIImageView()
    var sellerAvatar: UIButton! = UIButton()
    var viewIcon: UIImageView!
    var reportButton: UIButton!
    var favoriteButton: UIButton!
    var viewCount: UILabel!
    var favoriteCount: UILabel!
    var background: UIView!
    var buyButton: UIButton!
    var infoButton: UIButton!
    
    var infoView: UIView!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
    init(delegate: FavoriteProtocol?, id: Int, image: UIImage, avatar: UIImage, sellerSnapchatUsername: String, favorited: Bool) {
        super.init(nibName:nil, bundle:nil)
        
        productId = id
        
        self.productImage.image = image
        self.sellerAvatar.setImage(avatar, for: .normal)
        self.favorited = favorited
        self.delegate = delegate

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = .white
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productImage)

        sellerAvatar.contentMode = .scaleAspectFit
        sellerAvatar.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        sellerAvatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sellerAvatar)
        
        background = UIView()
        background.backgroundColor = .black
        background.alpha = 0.5
        background.layer.cornerRadius = 25
        background.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background)
        
        viewIcon = UIImageView()
        viewIcon.image = UIImage(named: "eye")
        viewIcon.contentMode = .scaleToFill
        viewIcon.clipsToBounds = true
        viewIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewIcon)
        
        viewCount = UILabel()
        viewCount.font = UIFont.init(name: "AvenirNext-DemiBold", size: 12.5)
        viewCount.text = 33333.roundedWithAbbreviations
        viewCount.textAlignment = .center
        viewCount.textColor = .white
        viewCount.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewCount)
        
        favoriteButton = UIButton()
        if favorited == false {
            let favoriteImage = UIImage(named: "heart")
            favoriteButton.setImage(favoriteImage, for: .normal)
        } else if favorited == true {
            let favoriteImageFill = UIImage(named: "heartfill")
            favoriteButton.setImage(favoriteImageFill, for: .normal)
        }
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favoriteButton)
        
        favoriteCount = UILabel()
        favoriteCount.font = UIFont.init(name: "AvenirNext-DemiBold", size: 12.5)
//        favoriteCount.text = 0.roundedWithAbbreviations
        favoriteCount.textAlignment = .center
        favoriteCount.textColor = .white
        favoriteCount.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favoriteCount)
        
        reportButton = UIButton()
        let reportImage = UIImage(named: "flag")
        reportButton.setImage(reportImage, for: .normal)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reportButton)
        
        buyButton = UIButton()
        buyButton.setTitle("Buy Now", for: .normal)
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        buyButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        buyButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        buyButton.layer.cornerRadius = 25
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buyButton)
        
        infoButton = UIButton()
        let infoImage = UIImage(named: "info")
        infoButton.setImage(infoImage, for: .normal)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        infoButton.backgroundColor = .white
        infoButton.layer.cornerRadius = 25
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoButton)
        
        infoView = UIView()
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 40
        infoView.alpha = 1.0
        infoView.isHidden = true
        infoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoView)
        

        setUpConstraints()
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([productImage.topAnchor.constraint(equalTo: view.topAnchor), productImage.bottomAnchor.constraint(equalTo: view.bottomAnchor), productImage.leadingAnchor.constraint(equalTo: view.leadingAnchor), productImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        NSLayoutConstraint.activate([sellerAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15), sellerAvatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25), sellerAvatar.trailingAnchor.constraint(equalTo: sellerAvatar.leadingAnchor, constant: 40), sellerAvatar.bottomAnchor.constraint(equalTo: sellerAvatar.topAnchor, constant: 40)])
        
        NSLayoutConstraint.activate([background.topAnchor.constraint(equalTo: sellerAvatar.topAnchor, constant: -5), background.trailingAnchor.constraint(equalTo: reportButton.trailingAnchor, constant: 20), background.leadingAnchor.constraint(equalTo: viewIcon.leadingAnchor, constant: -20), background.bottomAnchor.constraint(equalTo: viewCount.bottomAnchor, constant: 5)])
        
        NSLayoutConstraint.activate([viewIcon.centerYAnchor.constraint(equalTo: sellerAvatar.centerYAnchor), viewIcon.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -20)])
        
        NSLayoutConstraint.activate([viewCount.centerXAnchor.constraint(equalTo: viewIcon.centerXAnchor), viewCount.topAnchor.constraint(equalTo: viewIcon.bottomAnchor, constant: 7)])
        
        NSLayoutConstraint.activate([favoriteButton.centerYAnchor.constraint(equalTo: sellerAvatar.centerYAnchor), favoriteButton.trailingAnchor.constraint(equalTo: reportButton.leadingAnchor, constant: -20)])
        
        NSLayoutConstraint.activate([favoriteCount.centerXAnchor.constraint(equalTo: favoriteButton.centerXAnchor), favoriteCount.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 3)])
        
        NSLayoutConstraint.activate([reportButton.centerYAnchor.constraint(equalTo: sellerAvatar.centerYAnchor), reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)])
        
        NSLayoutConstraint.activate([buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30), buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), buyButton.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: -50), buyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 100)])
        
        NSLayoutConstraint.activate([infoButton.leadingAnchor.constraint(equalTo: buyButton.trailingAnchor, constant: 10), infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), infoButton.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: -50), infoButton.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: 60)])
        
        NSLayoutConstraint.activate([infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor) , infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor), infoView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 100), infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    @objc func avatarButtonTapped() {
        let alert = UIAlertController(title: "Would you like to block this user?", message: "Blocking this user removes them from your feed and prevents them from accessing any of your listings.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Block user"), style: .destructive, handler: { _ in
            
            NetworkManager.createBlock()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Don't block user"), style: .default, handler: { _ in

            self.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func buyButtonTapped() {
        showDropIn(clientTokenOrTokenizationKey: "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpGVXpJMU5pSXNJbXRwWkNJNklqSXdNVGd3TkRJMk1UWXRjMkZ1WkdKdmVDSXNJbWx6Y3lJNkltaDBkSEJ6T2k4dllYQnBMbk5oYm1SaWIzZ3VZbkpoYVc1MGNtVmxaMkYwWlhkaGVTNWpiMjBpZlEuZXlKbGVIQWlPakUyTVRFeU56a3dNemdzSW1wMGFTSTZJbUprTlRjeE16RXhMV1ExWXpRdE5ESTBOUzFoWkRGbExXTTJPRFk0WkRZME4yUTFNeUlzSW5OMVlpSTZJbU4wYUhOM05IcDBOV2hxTW1kd1puZ2lMQ0pwYzNNaU9pSm9kSFJ3Y3pvdkwyRndhUzV6WVc1a1ltOTRMbUp5WVdsdWRISmxaV2RoZEdWM1lYa3VZMjl0SWl3aWJXVnlZMmhoYm5RaU9uc2ljSFZpYkdsalgybGtJam9pWTNSb2MzYzBlblExYUdveVozQm1lQ0lzSW5abGNtbG1lVjlqWVhKa1gySjVYMlJsWm1GMWJIUWlPbVpoYkhObGZTd2ljbWxuYUhSeklqcGJJbTFoYm1GblpWOTJZWFZzZENKZExDSnpZMjl3WlNJNld5SkNjbUZwYm5SeVpXVTZWbUYxYkhRaVhTd2liM0IwYVc5dWN5STZlMzE5LmpfQ0JHNEpjaGxGX2RvajNOamZxSGItZWdxM3FSU1lyWWRIMkExME1YLW5peEpibm45VFpEWXFORjdzWDhnWTBQU0paT201MXhOejhHQzFfRTVzejV3IiwiY29uZmlnVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2N0aHN3NHp0NWhqMmdwZngvY2xpZW50X2FwaS92MS9jb25maWd1cmF0aW9uIiwiZ3JhcGhRTCI6eyJ1cmwiOiJodHRwczovL3BheW1lbnRzLnNhbmRib3guYnJhaW50cmVlLWFwaS5jb20vZ3JhcGhxbCIsImRhdGUiOiIyMDE4LTA1LTA4IiwiZmVhdHVyZXMiOlsidG9rZW5pemVfY3JlZGl0X2NhcmRzIl19LCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvY3Roc3c0enQ1aGoyZ3BmeC9jbGllbnRfYXBpIiwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwibWVyY2hhbnRJZCI6ImN0aHN3NHp0NWhqMmdwZngiLCJhc3NldHNVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImF1dGhVcmwiOiJodHRwczovL2F1dGgudmVubW8uc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbSIsInZlbm1vIjoib2ZmIiwiY2hhbGxlbmdlcyI6W10sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsImFuYWx5dGljcyI6eyJ1cmwiOiJodHRwczovL29yaWdpbi1hbmFseXRpY3Mtc2FuZC5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tL2N0aHN3NHp0NWhqMmdwZngifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6dHJ1ZSwiZW52aXJvbm1lbnROb05ldHdvcmsiOnRydWUsInVudmV0dGVkTWVyY2hhbnQiOmZhbHNlLCJhbGxvd0h0dHAiOnRydWUsImRpc3BsYXlOYW1lIjoiSGF5c3RhY2siLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwibWVyY2hhbnRBY2NvdW50SWQiOiJoYXlzdGFjayIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9fQ==")
    }
    
    @objc func infoButtonTapped() {
//        Analytics.logEvent("messaged_seller", parameters: nil)
//        if sellerSnapchatUsername.isEmpty == false {
//            UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/\(sellerSnapchatUsername!)")!)
//        } else {
//            UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/x")!)
//        }
    }

    @objc func favoriteButtonTapped() {
        if favorited == false {
            Analytics.logEvent("product_favorited", parameters: nil)
            let favoriteImageFill = UIImage(named: "heartfill")
            favoriteButton.setImage(favoriteImageFill, for: .normal)
            if favoriteCount.text == nil {
                favoriteCount.text = "1"
            } else {
                var count = Int(favoriteCount.text!)
                count! += 1
                favoriteCount.text = count!.roundedWithAbbreviations
            }
            favorited = true
            if defaults.bool(forKey: "did_request_review") == false {
                defaults.set(defaults.integer(forKey: "minimum_review_actions")+1, forKey: "minimum_review_actions")
            }
            if defaults.integer(forKey: "minimum_review_actions") == 2 {
                AppStoreReviewManager.requestReviewIfAppropriate()
                defaults.set(true, forKey: "did_request_review")
                defaults.set(defaults.integer(forKey: "minimum_review_actions")+1, forKey: "minimum_review_actions")
            }
            NetworkManager.createFavorite()
            delegate?.favoriteData(favorited: favorited)
        } else {
            Analytics.logEvent("product_unfavorited", parameters: nil)
            let favoriteImage = UIImage(named: "heart")
            favoriteButton.setImage(favoriteImage, for: .normal)
            var count = Int(favoriteCount.text!)
            count! -= 1
            if count == 0 {
                favoriteCount.text = nil
            } else {
                favoriteCount.text = count!.roundedWithAbbreviations
            }
            favorited = false
            if defaults.bool(forKey: "did_request_review") == false {
                defaults.set(defaults.integer(forKey: "minimum_review_actions")-1, forKey: "minimum_review_actions")
            }
            NetworkManager.removeFavorite()
            delegate?.favoriteData(favorited: favorited)
        }
    }
    
    @objc func reportButtonTapped() {
        Analytics.logEvent("report_button_pressed", parameters: nil)
        let vc = ReportViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            
            var velocityCheck : Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if otherGestureRecognizer == self.panGestureRecognizer {
            return true
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.transitionController.isInteractive = true
            if let _ = self.navigationController?.popViewController(animated: true) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
//                delegate?.favoriteData(favorited: favorited)
            }
            
        case .ended:
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            if self.transitionController.isInteractive {
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
                self.navigationController?.setNavigationBarHidden(true, animated: false)
            }
        default:
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.venmoDisabled = false
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }

}

extension ProductViewController: ZoomAnimatorDelegate {

    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        sellerAvatar.isHidden = true
        background.isHidden = true
        viewIcon.isHidden = true
        viewCount.isHidden = true
        favoriteButton.isHidden = true
        favoriteCount.isHidden = true
        reportButton.isHidden = true
        buyButton.isHidden = true
        infoButton.isHidden = true
    }

    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        sellerAvatar.isHidden = false
        background.isHidden = false
        viewIcon.isHidden = false
        viewCount.isHidden = false
        favoriteButton.isHidden = false
        favoriteCount.isHidden = false
        reportButton.isHidden = false
        buyButton.isHidden = false
        infoButton.isHidden = false
    }

    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.productImage
    }

    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.productImage.frame
    }
}

extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(self)"
        }
    }
}
