//
//  ProductViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 8/30/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import UIKit
import Firebase

var productId: Int! = 0

class ProductViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var delegate: FavoriteProtocol?
    
    var id: Int!
    var sellerSnapchatUsername: String!
    var favorited: Bool!
    
    var productImage: UIImageView! = UIImageView()
    var messageSellerButton: UIButton!
    var sellerAvatar: UIImageView! = UIImageView()
    var reportButton: UIButton!
    var favoriteButton: UIButton!
    
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
    init(delegate: FavoriteProtocol?, id: Int, image: UIImage, avatar: UIImage, sellerSnapchatUsername: String, favorited: Bool) {
        super.init(nibName:nil, bundle:nil)
        
        productId = id
        
        self.productImage.image = image
        self.sellerAvatar.image = avatar
        self.favorited = favorited
        self.sellerSnapchatUsername = sellerSnapchatUsername
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
        sellerAvatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sellerAvatar)
        
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
        
        reportButton = UIButton()
        let reportImage = UIImage(named: "flag")
        reportButton.setImage(reportImage, for: .normal)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reportButton)
        
        messageSellerButton = UIButton()
        messageSellerButton.setTitle("Message Seller", for: .normal)
        messageSellerButton.addTarget(self, action: #selector(messageSellerButtonTapped), for: .touchUpInside)
        messageSellerButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        messageSellerButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        messageSellerButton.layer.cornerRadius = 25
        messageSellerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageSellerButton)
        

        setUpConstraints()
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([productImage.topAnchor.constraint(equalTo: view.topAnchor), productImage.bottomAnchor.constraint(equalTo: view.bottomAnchor), productImage.leadingAnchor.constraint(equalTo: view.leadingAnchor), productImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        NSLayoutConstraint.activate([sellerAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15), sellerAvatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25), sellerAvatar.trailingAnchor.constraint(equalTo: sellerAvatar.leadingAnchor, constant: 40), sellerAvatar.bottomAnchor.constraint(equalTo: sellerAvatar.topAnchor, constant: 40)])
        
        NSLayoutConstraint.activate([favoriteButton.centerYAnchor.constraint(equalTo: sellerAvatar.centerYAnchor), favoriteButton.trailingAnchor.constraint(equalTo: reportButton.leadingAnchor, constant: -20)])
        
        NSLayoutConstraint.activate([reportButton.centerYAnchor.constraint(equalTo: sellerAvatar.centerYAnchor), reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)])
        
        NSLayoutConstraint.activate([messageSellerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150), messageSellerButton.topAnchor.constraint(equalTo: messageSellerButton.bottomAnchor, constant: -50), messageSellerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), messageSellerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150)])
    }
    
    @objc func messageSellerButtonTapped() {
        Analytics.logEvent("messaged_seller", parameters: nil)
        if sellerSnapchatUsername.isEmpty == false {
            UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/\(sellerSnapchatUsername!)")!)
        } else {
            UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/x")!)
        }
    }

    @objc func favoriteButtonTapped() {
        if favorited == false {
            Analytics.logEvent("product_favorited", parameters: nil)
            let favoriteImageFill = UIImage(named: "heartfill")
            favoriteButton.setImage(favoriteImageFill, for: .normal)
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
    
    

}

extension ProductViewController: ZoomAnimatorDelegate {

    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        sellerAvatar.isHidden = true
        messageSellerButton.isHidden = true
    }

    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        sellerAvatar.isHidden = false
        messageSellerButton.isHidden = false
    }

    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.productImage
    }

    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return self.productImage.frame
    }
}
