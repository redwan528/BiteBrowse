//
//  APIService.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation

import Foundation

class APIService {
    // API Key used for authorization with Yelp API.
    private let apiKey = "Bearer itoMaM6DJBtqD54BHSZQY9WdWR5xI_CnpZdxa3SG5i7N0M37VK1HklDDF4ifYh8SI-P2kI_mRj5KRSF4_FhTUAkEw322L8L8RY6bF1UB8jFx3TOR0-wW6Tk0KftNXXYx"
    
    // Base URL for Yelp's business search API.
    private let baseUrl = "https://api.yelp.com/v3/businesses/search"

    
    
    // Function to fetch restaurants based on latitude and longitude.
    // Completion handler returns an optional array of Restaurant or nil if an error occurs.
    func fetchRestaurants(latitude: Double, longitude: Double, completion: @escaping ([Restaurant]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)?latitude=\(latitude)&longitude=\(longitude)&categories=restaurants") else {
            completion(nil)
            return
        }
        
        // Creating a URLRequest object with the URL and setting the HTTP method to GET.
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        // Starting a URLSession data task to fetch data from the API.
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Guard statement to check if data was received successfully.
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            // Decoding the JSON data into a YelpResponse object
            let decoder = JSONDecoder()
            do {
                let responseData = try decoder.decode(YelpResponse.self, from: data)
                completion(responseData.businesses)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }.resume() // Starting the network request
    }
}

// Struct representing the JSON response structure from Yelp API
struct YelpResponse: Decodable {
    let businesses: [Restaurant]
}
