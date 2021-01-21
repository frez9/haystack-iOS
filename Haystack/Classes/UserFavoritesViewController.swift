//
//  UserFavoritesViewController.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
//

import UIKit

class UserFavoritesViewController: UIViewController, UIGestureRecognizerDelegate {

    var viewTranslation = CGPoint(x: 0, y: 0)
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    private let refreshControl = UIRefreshControl()

    var productCollectionView: UICollectionView!
    let productReuseIdentifier = "ProductReuse"
    let padding: CGFloat = 3

    var index: Product!
    var selectedIndexPath: IndexPath!
    
    var noFavoritesLabel: UILabel!
    
    var favorites: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        NetworkManager.getMyFavorites() { favorites in
            
            if favorites.count == 0 {
                self.noFavoritesLabel.isHidden = false
                self.productCollectionView.isHidden = true
            } else {
                self.noFavoritesLabel.isHidden = true
                self.productCollectionView.isHidden = false
                
                DispatchQueue.global().async {
               
                    for favorite in favorites {

                        let productImageUrl = URL(string: favorite.product_image_url)
                        let productImageData = try? Data(contentsOf: productImageUrl!)
                        let productImage = UIImage(data: productImageData!)!
                    
                        var avatarImage: UIImage = UIImage()
                    
                        if favorite.avatar_url != "nil" {
                            let avatarImageUrl = URL(string: favorite.avatar_url)
                            let avatarImageData = try? Data(contentsOf: avatarImageUrl!)
                            avatarImage = UIImage(data: avatarImageData!)!
                        } else {
                            avatarImage = UIImage(named: "profile")!
                        }
                
                        let convertedProduct = Product(id: favorite.id, product_image: productImage, avatar_image: avatarImage, seller_snapchat_username: favorite.seller_snapchat_username, is_favorited: favorite.is_favorited)
                
                        self.favorites.append(convertedProduct)
                        
                    }

                    DispatchQueue.main.async {
                        self.favorites.reverse()
                        self.productCollectionView.reloadData()
                        self.productCollectionView.isUserInteractionEnabled = true
                    }
                }
            }
        }
        
        noFavoritesLabel = UILabel()
        noFavoritesLabel.isHidden = true
        noFavoritesLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 20)
        noFavoritesLabel.text = "No favorites yet."
        noFavoritesLabel.textColor = .black
        noFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noFavoritesLabel)

        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePop))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)

        title = "My Favorites"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop"), style: .plain, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
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
        productCollectionView.isUserInteractionEnabled = false
        productCollectionView.showsVerticalScrollIndicator = true
        productCollectionView.alwaysBounceVertical = true
        productCollectionView.refreshControl = refreshControl
        productCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productCollectionView)

        setUpConstraints()

    }

    func setUpConstraints() {
        
        NSLayoutConstraint.activate([noFavoritesLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), noFavoritesLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50)])

        NSLayoutConstraint.activate([productCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding), productCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding), productCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), productCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

    }
    
    @objc func didPullToRefresh() {
        NetworkManager.getMyFavorites() { favorites in
            
            self.favorites.removeAll()
            
            if favorites.count == 0 {
                self.noFavoritesLabel.isHidden = false
                self.productCollectionView.isHidden = true
            } else {
                self.noFavoritesLabel.isHidden = true
                self.productCollectionView.isHidden = false
                
                DispatchQueue.global().async {
               
                    for favorite in favorites {

                        let productImageUrl = URL(string: favorite.product_image_url)
                        let productImageData = try? Data(contentsOf: productImageUrl!)
                        let productImage = UIImage(data: productImageData!)!
                    
                        var avatarImage: UIImage = UIImage()
                    
                        if favorite.avatar_url != "nil" {
                            let avatarImageUrl = URL(string: favorite.avatar_url)
                            let avatarImageData = try? Data(contentsOf: avatarImageUrl!)
                            avatarImage = UIImage(data: avatarImageData!)!
                        } else {
                            avatarImage = UIImage(named: "profile")!
                        }
                
                        let convertedProduct = Product(id: favorite.id, product_image: productImage, avatar_image: avatarImage, seller_snapchat_username: favorite.seller_snapchat_username, is_favorited: favorite.is_favorited)
                
                        self.favorites.append(convertedProduct)
                        
                    }

                    DispatchQueue.main.async {
                        self.favorites.reverse()
                        self.productCollectionView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.productCollectionView.isUserInteractionEnabled = true
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

}

extension UserFavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 2 * padding) / 3.0
        return CGSize(width: width, height: 170)
    }

}

extension UserFavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = favorites[indexPath.row]
        self.selectedIndexPath = indexPath
        let nav = self.navigationController
        let vc = ProductViewController(delegate: self, id: index.id, image: index.product_image, avatar: index.avatar_image, sellerSnapchatUsername: index.seller_snapchat_username, favorited: index.is_favorited)
        nav?.delegate = vc.transitionController
        vc.transitionController.fromDelegate = self
        vc.transitionController.toDelegate = vc
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if favorites.isEmpty {
            return 15
        }
        return favorites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCollectionViewCell
        cell.productImage.image = nil
        if favorites.isEmpty {
            cell.configure3()
        } else {
            let dataModel = favorites[indexPath.item]
            cell.homeConfigure(product: dataModel)
        }
        return cell
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

extension UserFavoritesViewController: ZoomAnimatorDelegate {

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

extension UserFavoritesViewController: FavoriteProtocol {
    func favoriteData(favorited: Bool!) {
        favorites[selectedIndexPath.row].is_favorited = favorited
    }
}

