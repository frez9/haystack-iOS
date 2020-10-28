//
//  HomeViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 8/27/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import UIKit
import Firebase

protocol FavoriteProtocol: class {
    func favoriteData(favorited: Bool!)
}

var viewInt = 5

var pageNumber: Int! = 1

class HomeViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()

    var productCollectionView: UICollectionView!
    let productReuseIdentifier = "ProductReuse"
    let padding: CGFloat = 3
    var sellButton: UIButton!

    var index: Product!
    var selectedIndexPath: IndexPath!

    var products: [Product] = []
    
    var preventLoad: Bool!
    
    override func viewDidAppear(_ animated: Bool) {

        if defaults.bool(forKey: "did_accept_add_request") == false {
            
            if defaults.integer(forKey: "product_views") == viewInt {
                
                let alert = UIAlertController(title: "Add Haystack on Snapchat", message: "Get the latest on exclusive deals, great coupons, and much more!", preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Add on Snapchat"), style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: "https://www.snapchat.com/add/haystack_app")!)
                    defaults.set(true, forKey: "did_accept_add_request")
                }))
            
                alert.addAction(UIAlertAction(title: NSLocalizedString("Not Now", comment: "Remind"), style: .default, handler: { _ in
                    
                    defaults.set(-10, forKey: "product_views")
                }))
            
                self.present(alert, animated: true, completion: nil)
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        preventLoad = false
        
        NetworkManager.getProducts() { products in

            for product in products {
                
                DispatchQueue.global().async {

                    let productImageUrl = URL(string: product.product_image_url)
                    let productImageData = try? Data(contentsOf: productImageUrl!)
                    let productImage = UIImage(data: productImageData!)!

                    var avatarImage: UIImage = UIImage()

                    if product.avatar_url != "nil" {
                        let avatarImageUrl = URL(string: product.avatar_url)
                        let avatarImageData = try? Data(contentsOf: avatarImageUrl!)
                        avatarImage = UIImage(data: avatarImageData!)!
                    } else {
                        avatarImage = UIImage(named: "profile")!
                    }

                    let convertedProduct = Product(id: product.id, product_image: productImage, avatar_image: avatarImage, seller_snapchat_username: product.seller_snapchat_username, is_favorited: product.is_favorited)
                
                    self.products.append(convertedProduct)

                    DispatchQueue.main.async {
                        self.productCollectionView.reloadData()
                    }
                }
            }
        }

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let avatarView = UIImageView()
        avatarView.contentMode = .scaleAspectFit
        if defaults.string(forKey: "avatar_url")! == "nil" {
            let avatarImage = UIImage(named: "profile")
            avatarView.image = avatarImage
        } else {
            let url = URL(string: "\(defaults.string(forKey: "avatar_url")!)")
            if let data = try? Data(contentsOf: url!) {
                let image: UIImage = UIImage(data: data)!
                avatarView.image = image
            }
        }
        self.navigationItem.titleView = avatarView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped))
        self.navigationItem.titleView?.addGestureRecognizer(recognizer)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding

        productCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        productCollectionView.backgroundColor = .white
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: productReuseIdentifier)
        productCollectionView.showsVerticalScrollIndicator = false
        productCollectionView.alwaysBounceVertical = true
        productCollectionView.refreshControl = refreshControl
        productCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productCollectionView)
        
        sellButton = UIButton()
        sellButton.setTitle("  Sell", for: .normal)
        let cameraImage = UIImage(named: "camera")
        sellButton.setImage(cameraImage, for: .normal)
        sellButton.addTarget(self, action: #selector(sellButtonTapped), for: .touchUpInside)
        sellButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        sellButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        sellButton.layer.cornerRadius = 20
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sellButton)
        
        
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        
        NSLayoutConstraint.activate([productCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding), productCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding), productCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), productCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        NSLayoutConstraint.activate([sellButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -85), sellButton.topAnchor.constraint(equalTo: sellButton.bottomAnchor, constant: -45), sellButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), sellButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 85)])
        
        
    }
    
    @objc func didPullToRefresh() {
        pageNumber = 1
        NetworkManager.getProducts() { products in
            
            self.products.removeAll()

            for product in products {
                
                DispatchQueue.global().async {

                    let productImageUrl = URL(string: product.product_image_url)
                    let productImageData = try? Data(contentsOf: productImageUrl!)
                    let productImage = UIImage(data: productImageData!)!
                
                    var avatarImage: UIImage = UIImage()
                
                    if product.avatar_url != "nil" {
                        let avatarImageUrl = URL(string: product.avatar_url)
                        let avatarImageData = try? Data(contentsOf: avatarImageUrl!)
                        avatarImage = UIImage(data: avatarImageData!)!
                    } else {
                        avatarImage = UIImage(named: "profile")!
                    }
                
                    let newProduct = Product(id: product.id, product_image: productImage, avatar_image: avatarImage, seller_snapchat_username: product.seller_snapchat_username, is_favorited: product.is_favorited)
                
                    self.products.append(newProduct)

                    DispatchQueue.main.async {
                        self.productCollectionView.reloadData()
                        self.refreshControl.endRefreshing()
//                        self.productCollectionView.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @objc func sellButtonTapped() {
        Analytics.logEvent("sell_button_pressed", parameters: nil)
        let vc = CameraViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    @objc func profileButtonTapped() {
        Analytics.logEvent("profile_button_pressed", parameters: nil)
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 2 * padding) / 3.0
        return CGSize(width: width, height: 170)
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = products[indexPath.item]
        self.selectedIndexPath = indexPath
        let nav = self.navigationController
        let vc = ProductViewController(delegate: self, id: index.id, image: index.product_image, avatar: index.avatar_image, sellerSnapchatUsername: index.seller_snapchat_username, favorited: index.is_favorited)
        nav?.delegate = vc.transitionController
        vc.transitionController.fromDelegate = self
        vc.transitionController.toDelegate = vc
        self.navigationController?.pushViewController(vc, animated: true)
        if defaults.bool(forKey: "did_accept_add_request") == false {
            defaults.set(defaults.integer(forKey: "product_views")+1, forKey: "product_views")
        }
        Analytics.logEvent("product_viewed", parameters: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if products.isEmpty {
            return 12
        }
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCollectionViewCell
        cell.productImage.image = nil
        if products.isEmpty {
            cell.configure3()
        } else {
            let dataModel = products[indexPath.item]
            cell.configure(product: dataModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == products.count - 1 {
//            pageNumber += 1
//
//            if preventLoad == false {
//
//                NetworkManager.getProducts() { products in
//
//                    if products.isEmpty == false {
//
//                        for product in products.reversed() {
//
//                            DispatchQueue.global().async {
//
//                                let productImageUrl = URL(string: product.product_image_url)
//                                let productImageData = try? Data(contentsOf: productImageUrl!)
//                                let productImage = UIImage(data: productImageData!)!
//
//                                var avatarImage: UIImage = UIImage()
//
//                                if product.avatar_url != "nil" {
//                                    let avatarImageUrl = URL(string: product.avatar_url)
//                                    let avatarImageData = try? Data(contentsOf: avatarImageUrl!)
//                                    avatarImage = UIImage(data: avatarImageData!)!
//                                } else {
//                                    avatarImage = UIImage(named: "profile")!
//                                }
//
//                                let newProduct = Product(id: product.id, product_image: productImage, avatar_image: avatarImage, seller_snapchat_username: product.seller_snapchat_username, is_favorited: product.is_favorited)
//
//                                self.products.append(newProduct)
//
//                                DispatchQueue.main.async {
//                                    self.productCollectionView.reloadData()
//                                }
//                            }
//                        }
//
//                    } else {
//                        self.preventLoad = true
//                    }
//                }
//            }
//        }
    }

 //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.productCollectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {

            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.productCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.productCollectionView.reloadItems(at: self.productCollectionView.indexPathsForVisibleItems)
            self.productCollectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.productCollectionView.cellForItem(at: self.selectedIndexPath) as? ProductCollectionViewCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.productImage
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = self.productCollectionView.cellForItem(at: self.selectedIndexPath) as? ProductCollectionViewCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.productImage
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = self.productCollectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.productCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.productCollectionView.reloadItems(at: self.productCollectionView.indexPathsForVisibleItems)
            self.productCollectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.productCollectionView.cellForItem(at: self.selectedIndexPath) as? ProductCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.productCollectionView.cellForItem(at: self.selectedIndexPath) as? ProductCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
}

extension HomeViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {

        let cell = self.productCollectionView.cellForItem(at: self.selectedIndexPath) as! ProductCollectionViewCell

        let cellFrame = self.productCollectionView.convert(cell.frame, to: self.view)

        if cellFrame.minY < self.productCollectionView.contentInset.top {
            self.productCollectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
            
        } else if cellFrame.maxY > self.view.frame.height - self.productCollectionView.contentInset.bottom {
            self.productCollectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        self.view.layoutIfNeeded()
        self.productCollectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        let cellFrame = self.productCollectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.productCollectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.productCollectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.productCollectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}

extension HomeViewController: FavoriteProtocol {
    func favoriteData(favorited: Bool!) {
        products[selectedIndexPath.row].is_favorited = favorited
    }
}
