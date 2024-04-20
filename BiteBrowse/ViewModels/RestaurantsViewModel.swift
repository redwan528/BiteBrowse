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
    private var locationManager = LocationManager()
    private var cancellables: Set<AnyCancellable> = []
    
    private var limiter = APIRateLimiter(interval: 1.0)  // Assuming 1 second between requests

    
    @Published var currentRestaurantIndex = 0 // tracks current index of visible restaurant card
    @Published var radius = 1000 //starting raduis in meters
    
    
//    func loadRestaurantsIfNeeded() {
//        guard shouldFetchMoreRestaurants(), let currentLocation = locationManager.currentLocation else {
//            return // TODO: need to handle the case where location is nil, notify the user or use default location
//        }
//
//        apiService.fetchRestaurants(latitude: currentLocation.latitude, longitude: currentLocation.longitude, radius: radius) { [weak self] newRestaurants in
//            guard let self = self, let newRestaurants = newRestaurants else { return }
//
//            DispatchQueue.main.async {
//                self.restaurants.append(contentsOf: newRestaurants)
//                self.radius += 1000 // Increase the radius for the next fetch
//            }
//        }
//    }
    func loadRestaurantsIfNeeded() {
        print("Current radius: \(radius)")
        guard shouldFetchMoreRestaurants(), let currentLocation = locationManager.currentLocation else {
            print("Location unavailable or no need to fetch more restaurants")
            return // Optionally handle the nil location case here
        }

        print("Fetching restaurants with radius: \(radius)")
        apiService.fetchRestaurants(latitude: currentLocation.latitude, longitude: currentLocation.longitude, radius: radius) { [weak self] newRestaurants in
            guard let self = self, let newRestaurants = newRestaurants else { return }
            DispatchQueue.main.async {
                self.restaurants.append(contentsOf: newRestaurants)
                self.radius += 1000 // TODO: need to handle the case where location is nil, notify the user or use default location
                print("Radius increased to: \(self.radius)")
            }
        }
    }


    private func shouldFetchMoreRestaurants() -> Bool {
        let threshold = restaurants.count - 5
        print("Current index: \(currentRestaurantIndex), Threshold: \(threshold)")
        return currentRestaurantIndex >= threshold
    }

    
    
    //computed property to get current restuarant
    var currentRestaurant: Restaurant? {
        guard currentRestaurantIndex >= 0 && currentRestaurantIndex < restaurants.count else {return nil}
        return restaurants[currentRestaurantIndex]
    }
    
    
    init() {
          // location updates
          locationManager.$currentLocation
              .compactMap { $0 } // Ensure that the location is not nil
              .receive(on: DispatchQueue.main) // Ensure to receive on main thread
              .sink { [weak self] location in
                //  self?.loadRestaurants(latitude: location.latitude, longitude: location.longitude)
                  self!.loadRestaurants()
              }
              .store(in: &cancellables)
        loadRestaurantsIfNeeded()
      }
    
//      func loadRestaurants(latitude: Double, longitude: Double) {
//          apiService.fetchRestaurants(latitude: latitude, longitude: longitude, radius: radius) { [weak self] (restaurants) in
//              self?.restaurants = restaurants ?? []
//          }
//      }
    func loadRestaurants() {
        guard let location = locationManager.currentLocation else {
               print("Current location is not available.")
               return
           }
           
           limiter.perform { [weak self] in
               guard let self = self else { return }
               self.apiService.fetchRestaurants(latitude: location.latitude, longitude: location.longitude, radius: 1000) { newRestaurants in
                   if let newRestaurants = newRestaurants {
                       DispatchQueue.main.async {
                           self.restaurants.append(contentsOf: newRestaurants)
                           // Potentially update the UI or handle next steps
                       }
                   }
               }
           }
       }


    
    // moves to the next restaurant in the list
      func showNextRestaurant() {
          if currentRestaurantIndex < restaurants.count - 1 {
              currentRestaurantIndex += 1
          }
      }

      // moves to the previous restaurant in the list
      func showPreviousRestaurant() {
          if currentRestaurantIndex > 0 {
              currentRestaurantIndex -= 1
          }
      }

}
