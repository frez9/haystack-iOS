//
//  NetworkManager.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 10/16/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

let endpoint = "http://35.231.51.48/api/listings/11111/1/"
let userCreationEndpoint = "http://35.231.51.48/api/users/create/"
let listingCreationEndpoint = "http://35.231.51.48/api/listings/create/"
let usernameUpdateEndpoint = "http://35.231.51.48/api/users/username/update/"
let getMyListingsEndpoint = "http://35.231.51.48/api/listings/my/"
let deleteListingEndpoint = "http://35.231.51.48/api/listings/delete/"
let getMyFavoritesEndpoint = "http://35.231.51.48/api/favorites/my/"
let favoriteCreationEndpoint = "http://35.231.51.48/api/favorites/create/"
let removeFavoriteEndpoint = "http://35.231.51.48/api/favorites/remove/"
let getProductsEndpoint = "http://35.231.51.48/api/listings/paginated/"
let reportCreationEndpoint = "http://35.231.51.48/api/reports/create/"

enum ExampleDataResponse<T: Any> {
    case success(data: T)
    case failure(error: Error)
}

let defaults = UserDefaults.standard

class NetworkManager {

    static func createUser() {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "avatar_url": defaults.string(forKey: "avatar_url")!
        ]
        AF.request(userCreationEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func createListing(finished: @escaping () -> Void) {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "product_image_url": productImageURL!
        ]
        AF.request(listingCreationEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                finished()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func updateSnapchatUsername() {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "snapchat_username": defaults.string(forKey: "snapchat_username")!
        ]
        AF.request(usernameUpdateEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func getMyListings(completion: @escaping (([ListingObject]) -> Void)) {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!
        ]
        AF.request(getMyListingsEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                
                let decoder = JSONDecoder()
                
                if let listingData = try? decoder.decode(ListingDataResponse.self, from: data) {
        
                    let listings = listingData.data
                    
                    completion(listings)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func deleteListing() {
        let parameters: [String: Any] = [
            "listing_id": listingId!
        ]
        AF.request(deleteListingEndpoint, method: .delete, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func getMyFavorites(completion: @escaping (([ProductObject]) -> Void)) {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!
        ]
        AF.request(getMyFavoritesEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                
                let decoder = JSONDecoder()
                
                if let favoriteData = try? decoder.decode(ProductDataResponse.self, from: data) {
        
                    let favorites = favoriteData.data

                    completion(favorites)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func createFavorite() {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "listing_id": productId!
        ]
        AF.request(favoriteCreationEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func removeFavorite() {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "listing_id": productId!
        ]
        AF.request(removeFavoriteEndpoint, method: .delete, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func getProducts(completion: @escaping (([ProductObject]) -> Void)) {
        let parameters: [String: Any] = [
            "external_id": defaults.string(forKey: "external_id")!,
            "page_number": pageNumber!
        ]
        AF.request(getProductsEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)

                let decoder = JSONDecoder()

                if let productData = try? decoder.decode(ProductDataResponse.self, from: data) {

                    let products = productData.data

                    completion(products)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func createReport() {
        let parameters: [String: Any] = [
            "listing_id": productId!,
            "report": report!
        ]
        AF.request(reportCreationEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

// Username Decodables

struct UsernameObject: Codable {
    var snapchat_username: String
}

struct UsernameDataResponse: Codable {
    var success: Bool
    var data: UsernameObject
}

//Listing Decodables

struct ListingObject: Decodable {
    var id: Int
    var product_image_url: String
}

struct ListingDataResponse: Decodable {
    var success: Bool
    var data: [ListingObject]
}

//Product Decodables

struct ProductObject: Decodable {
    var id: Int
    var product_image_url: String
    var avatar_url: String
    var seller_snapchat_username: String
    var is_favorited: Bool
}

struct ProductDataResponse: Decodable {
    var success: Bool
    var data: [ProductObject]
}

//Product Struct (used to improve scroll performance by converting product image URLs to UIImage objects within the get products network call completion)

struct Product {
    var id: Int
    var product_image: UIImage
    var avatar_image: UIImage
    var seller_snapchat_username: String
    var is_favorited: Bool
}

//Listing Struct (used to improve scroll performance by converting product image URLs to UIImage objects within the get products network call completion)

struct Listing {
    var id: Int
    var product_image: UIImage
    var image_storage_reference: StorageReference
}
