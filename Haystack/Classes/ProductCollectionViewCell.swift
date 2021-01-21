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
    
    var priceBar: UIView!
    var price: UILabel!
    
    var analyticsBar: UIView!
    var viewIcon: UIImageView!
    var viewCount: UILabel!
    var favoriteIcon: UIImageView!
    var favoriteCount: UILabel!
    
    var soldBar: UIView!
    var soldLabel: UILabel!
    
    override init(frame: CGRect) {
    super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        productImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productImage)
        
        priceBar = UIView()
        priceBar.backgroundColor = .black
        priceBar.alpha = 0.75
        priceBar.layer.cornerRadius = 5
        priceBar.isHidden = true
        priceBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceBar)
        
        price = UILabel()
        price.text = "$20"
        price.font = UIFont.init(name: "AvenirNext-DemiBold", size: 10)
        price.textAlignment = .center
        price.textColor = .white
        price.isHidden = true
        price.translatesAutoresizingMaskIntoConstraints = false
        priceBar.addSubview(price)
        
        analyticsBar = UIView()
        analyticsBar.backgroundColor = .black
        analyticsBar.alpha = 0.85
        analyticsBar.isHidden = true
        analyticsBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(analyticsBar)
        
        viewIcon = UIImageView()
        viewIcon.image = UIImage(named: "eye")
        viewIcon.contentMode = .scaleToFill
        viewIcon.clipsToBounds = true
        viewIcon.isHidden = true
        viewIcon.translatesAutoresizingMaskIntoConstraints = false
        analyticsBar.addSubview(viewIcon)
        
        viewCount = UILabel()
        viewCount.text = 11.roundedWithAbbreviations
        viewCount.font = UIFont.init(name: "AvenirNext-DemiBold", size: 12.5)
        viewCount.textAlignment = .center
        viewCount.textColor = .white
        viewCount.isHidden = true
        viewCount.translatesAutoresizingMaskIntoConstraints = false
        analyticsBar.addSubview(viewCount)
        
        favoriteIcon = UIImageView()
        favoriteIcon.image = UIImage(named: "heartfill")
        favoriteIcon.contentMode = .scaleToFill
        favoriteIcon.clipsToBounds = true
        favoriteIcon.isHidden = true
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        analyticsBar.addSubview(favoriteIcon)
        
        favoriteCount = UILabel()
        favoriteCount.text = 12.roundedWithAbbreviations
        favoriteCount.font = UIFont.init(name: "AvenirNext-DemiBold", size: 12.5)
        favoriteCount.textAlignment = .center
        favoriteCount.textColor = .white
        favoriteCount.isHidden = true
        favoriteCount.translatesAutoresizingMaskIntoConstraints = false
        analyticsBar.addSubview(favoriteCount)
        
        soldBar = UIView()
        soldBar.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        soldBar.isHidden = true
        soldBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(soldBar)
        
        soldLabel = UILabel()
        soldLabel.text = "SOLD"
        soldLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 15)
        soldLabel.textAlignment = .center
        soldLabel.textColor = .white
        soldLabel.isHidden = true
        soldLabel.translatesAutoresizingMaskIntoConstraints = false
        soldBar.addSubview(soldLabel)
        
        setUpConstraints()
    
    }
    
    func homeConfigure(product: Product) {
        contentView.backgroundColor = .white
        productImage.image = product.product_image
        priceBar.isHidden = false
        price.isHidden = false
        soldBar.isHidden = false
        soldLabel.isHidden = false
    }
    
    func myListingsConfigure(listing: Listing) {
        contentView.backgroundColor = .white
        productImage.image = listing.product_image
        analyticsBar.isHidden = false
        viewIcon.isHidden = false
        viewCount.isHidden = false
        favoriteIcon.isHidden = false
        favoriteCount.isHidden = false
        
        
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
        
        NSLayoutConstraint.activate([priceBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), priceBar.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -25), priceBar.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 70), priceBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
        
        NSLayoutConstraint.activate([price.centerXAnchor.constraint(equalTo: priceBar.centerXAnchor), price.centerYAnchor.constraint(equalTo: priceBar.centerYAnchor)])
        
        NSLayoutConstraint.activate([soldBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), soldBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), soldBar.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10), soldBar.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10)])
        
        NSLayoutConstraint.activate([soldLabel.centerXAnchor.constraint(equalTo: soldBar.centerXAnchor), soldLabel.centerYAnchor.constraint(equalTo: soldBar.centerYAnchor)])
        
        NSLayoutConstraint.activate([analyticsBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), analyticsBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), analyticsBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor), analyticsBar.topAnchor.constraint(equalTo: analyticsBar.bottomAnchor, constant: -25)])
        
        NSLayoutConstraint.activate([viewIcon.leadingAnchor.constraint(equalTo: analyticsBar.leadingAnchor, constant: 15), viewIcon.trailingAnchor.constraint(equalTo: analyticsBar.centerXAnchor, constant: -30), viewIcon.topAnchor.constraint(equalTo: analyticsBar.topAnchor, constant: 5), viewIcon.bottomAnchor.constraint(equalTo: analyticsBar.bottomAnchor, constant: -5)])

        NSLayoutConstraint.activate([viewCount.leadingAnchor.constraint(equalTo: viewIcon.trailingAnchor, constant: 5), viewCount.centerYAnchor.constraint(equalTo: viewIcon.centerYAnchor)])

        NSLayoutConstraint.activate([favoriteIcon.leadingAnchor.constraint(equalTo: analyticsBar.centerXAnchor, constant: 15), favoriteIcon.topAnchor.constraint(equalTo: analyticsBar.topAnchor, constant: 5), favoriteIcon.bottomAnchor.constraint(equalTo: analyticsBar.bottomAnchor, constant: -5), favoriteIcon.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: 20)])

        NSLayoutConstraint.activate([favoriteCount.leadingAnchor.constraint(equalTo: favoriteIcon.trailingAnchor, constant: 5), favoriteCount.centerYAnchor.constraint(equalTo: favoriteIcon.centerYAnchor)])
        
    }
    
}
