//
//  ProductCollectionViewCell.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    var productImage: UIImageView!
    
    override init(frame: CGRect) {
    super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        productImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productImage)
        
        setUpConstraints()
    
    }
    
    func configure(product: Product) {
        contentView.backgroundColor = .white
        productImage.image = product.product_image
    }
    
    func configure2(listing: Listing) {
        contentView.backgroundColor = .white
        productImage.image = listing.product_image
    }
    
    func configure3() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.contentView.backgroundColor = .lightGray
        })
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([productImage.topAnchor.constraint(equalTo: contentView.topAnchor), productImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor), productImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), productImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])
    }
    
}
