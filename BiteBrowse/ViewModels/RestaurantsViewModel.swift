//
//  RestaurantsViewModel.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation
import Combine

// ViewModel for managing the state and logic of restaurant views
class RestaurantsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = [] // Published property to store list of restaurants
    private var apiService: APIService = APIService() // Instance of APIService to fetch restaurant data

    // Function to load restaurants using coordinates
    func loadRestaurants(latitude: Double, longitude: Double) {
        apiService.fetchRestaurants(latitude: latitude, longitude: longitude) { [weak self] (restaurants) in
            DispatchQueue.main.async {
                self?.restaurants = restaurants ?? [] // Updating restaurants on the main thread
            }
        }
    }
}
