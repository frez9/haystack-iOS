//
//  UserProductsViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 9/29/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import UIKit
import Firebase

var listingId: Int! = 0

class UserProductsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    let refreshControl = UIRefreshControl()
    
    var productCollectionView: UICollectionView!
    let productReuseIdentifier = "ProductReuse"
    let padding: CGFloat = 3
    
    var deleteButton: UIButton!
    
    var noListingsLabel: UILabel!
    
    var listings: [Listing] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        NetworkManager.getMyListings() { listings in
            
            if listings.count == 0 {
                self.noListingsLabel.isHidden = false
                self.productCollectionView.isHidden = true
            } else {
                self.noListingsLabel.isHidden = true
                self.productCollectionView.isHidden = false
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.trashButtonTapped))
                self.navigationItem.rightBarButtonItem?.tintColor = .black
                
                DispatchQueue.global().async {
            
                    for listing in listings {
                    
                        let storage = Storage.storage()
                        let productImageReference = storage.reference(forURL: listing.product_image_url)

                        let productImageUrl = URL(string: listing.product_image_url)
                        let productImageData = try? Data(contentsOf: productImageUrl!)
                        let productImage = UIImage(data: productImageData!)!
                
                        let convertedProduct = Listing(id: listing.id, product_image: productImage, image_storage_reference: productImageReference)
                
                        self.listings.append(convertedProduct)
                        
                    }

                    DispatchQueue.main.async {
                        self.productCollectionView.reloadData()
                    }
                }
            }
        }
        
        noListingsLabel = UILabel()
        noListingsLabel.isHidden = true
        noListingsLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 20)
        noListingsLabel.text = "No listings yet."
        noListingsLabel.textColor = .black
        noListingsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noListingsLabel)
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePop))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        title = "My Listings"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop"), style: .plain, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.rightBarButtonItem = nil
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        productCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        productCollectionView.backgroundColor = .white
        productCollectionView.allowsSelection = false
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: productReuseIdentifier)
        productCollectionView.showsVerticalScrollIndicator = true
        productCollectionView.alwaysBounceVertical = true
        productCollectionView.refreshControl = refreshControl
        productCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productCollectionView)
        
        deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.isHidden = true
        deleteButton.isUserInteractionEnabled = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        deleteButton.backgroundColor = .lightGray
        deleteButton.layer.cornerRadius = 25
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        
        NSLayoutConstraint.activate([noListingsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), noListingsLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50)])
        
        NSLayoutConstraint.activate([productCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding), productCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding), productCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), productCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        NSLayoutConstraint.activate([deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150), deleteButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: -50), deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150)])
        
    }
    
    @objc func didPullToRefresh() {
        NetworkManager.getMyListings() { listings in
            
            self.listings.removeAll()
            
            if listings.count == 0 {
                self.noListingsLabel.isHidden = false
                self.productCollectionView.isHidden = true
            } else {
                self.noListingsLabel.isHidden = true
                self.productCollectionView.isHidden = false
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.trashButtonTapped))
                self.navigationItem.rightBarButtonItem?.tintColor = .black
                
                DispatchQueue.global().async {
            
                    for listing in listings {
                    
                        let storage = Storage.storage()
                        let productImageReference = storage.reference(forURL: listing.product_image_url)

                        let productImageUrl = URL(string: listing.product_image_url)
                        let productImageData = try? Data(contentsOf: productImageUrl!)
                        let productImage = UIImage(data: productImageData!)!
                
                        let convertedProduct = Listing(id: listing.id, product_image: productImage, image_storage_reference: productImageReference)
                
                        self.listings.append(convertedProduct)
                        
                    }

                    DispatchQueue.main.async {
                        self.productCollectionView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePop(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            break

        case .ended:
            viewTranslation = sender.translation(in: view)
            if viewTranslation.x > 0 {
                self.navigationController?.popViewController(animated: true)
            }

        default:
            break
        }
        
    }
    
    @objc func trashButtonTapped() {
        deleteButton.isHidden = false
        deleteButton.isUserInteractionEnabled = true
        productCollectionView.allowsSelection = true
        productCollectionView.allowsMultipleSelection = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func deleteButtonTapped() {
        if let selectedCells = productCollectionView.indexPathsForSelectedItems {
            
            Analytics.logEvent("listing_deleted", parameters: ["count": selectedCells.count])
            
            let items = selectedCells.map { $0.item }.sorted().reversed()
            
            for item in items {
                listingId = listings[item].id
                NetworkManager.deleteListing()
                listings[item].image_storage_reference.delete(completion: nil)
                listings.remove(at: item)
                
            }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop"), style: .plain, target: self, action: #selector(popVC))
            self.navigationItem.leftBarButtonItem?.tintColor = .black
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonTapped))
            self.navigationItem.rightBarButtonItem?.tintColor = .black
            productCollectionView.deleteItems(at: selectedCells)
            deleteButton.isHidden = true
            deleteButton.backgroundColor = .lightGray
            for index in productCollectionView.indexPathsForSelectedItems ?? [] {
                let cell = productCollectionView.cellForItem(at: index) as! ProductCollectionViewCell
                cell.productImage.alpha = 1
            }
            productCollectionView.allowsSelection = false
            }
    }
    
    @objc func cancelButtonTapped() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop"), style: .plain, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .lightGray
        for index in productCollectionView.indexPathsForSelectedItems ?? [] {
            let cell = productCollectionView.cellForItem(at: index) as! ProductCollectionViewCell
            cell.productImage.alpha = 1
        }
        productCollectionView.allowsSelection = false
    }

}

extension UserProductsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 2 * padding) / 3.0
        return CGSize(width: width, height: 170)
    }

}

extension UserProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if productCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0 {
            deleteButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        }
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell
        cell.productImage.alpha = 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if productCollectionView.indexPathsForSelectedItems?.count ?? 0 == 0 {
            deleteButton.backgroundColor = .lightGray
        }
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell
        cell.productImage.alpha = 1
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listings.isEmpty {
            return 12
        }
        return listings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCollectionViewCell
        cell.productImage.image = nil
        if listings.isEmpty {
            cell.configure3()
        } else {
            let dataModel = listings[indexPath.item]
            cell.configure2(listing: dataModel)
        }
        return cell
    }

}
