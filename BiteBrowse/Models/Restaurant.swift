//
//  Restaurant.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/18/24.
//

import Foundation


// Model struct for a restaurant, conforming to Identifiable and Decodable for use in SwiftUI views and JSON decoding
// Restaurant model adapted to the data structure from Yelp
struct Restaurant: Decodable {
    let id: String
    let name: String
    let imageUrl: String
    let rating: Double
    let location: Location
    let phone: String
    let reviewCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, phone
        case imageUrl = "image_url"
        case rating
        case reviewCount = "review_count"
        case location
    }

    struct Location: Decodable {
        let address1: String?
        let address2: String?
        let address3: String?
        let city: String
        let zipCode: String
        let country: String
        let state: String

        enum CodingKeys: String, CodingKey {
            case address1, address2, address3, city
            case zipCode = "zip_code"
            case country, state
        }
    }
}
