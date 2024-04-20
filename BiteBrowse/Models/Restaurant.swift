//
//  Restaurant.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/18/24.
//

import Foundation


// Model struct for a restaurant, conforming to Identifiable and Decodable for use in SwiftUI views and JSON decoding
struct Restaurant: Identifiable, Decodable {
    let id: String
    let name: String
    let imageUrl: String
    let rating: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url" // Custom key to map image_url from JSON to imageUrl property
        case rating
    }
}
