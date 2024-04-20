//
//  APIService.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation

class APIService {
    // API Key used for authorization with Yelp API
    private let apiKey = "Bearer itoMaM6DJBtqD54BHSZQY9WdWR5xI_CnpZdxa3SG5i7N0M37VK1HklDDF4ifYh8SI-P2kI_mRj5KRSF4_FhTUAkEw322L8L8RY6bF1UB8jFx3TOR0-wW6Tk0KftNXXYx"
    
    // Base URL for Yelp's business search API
    private let baseUrl =  "https://api.yelp.com/v3/businesses/search"

    func fetchRestaurants(latitude: Double, longitude: Double, radius: Int, offset: Int, limit: Int = 0, completion: @escaping ([Restaurant]?) -> Void) {
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "categories", value: "restaurants")
        ]
            
            guard let url = components?.url else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        completion(nil)
                        return
                    }
                    let decoder = JSONDecoder()
                    if let responseData = try? decoder.decode(YelpResponse.self, from: data) {
                        completion(responseData.businesses)
                    } else {
                        completion(nil)
                    }
                }
            }.resume()
        }
    
    // Struct representing the JSON response structure from Yelp API
    struct YelpResponse: Decodable {
        let businesses: [Restaurant]
    }
}
