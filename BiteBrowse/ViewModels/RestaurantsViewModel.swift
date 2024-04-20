//
//  RestaurantsViewModel.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation
import Combine
import CoreLocation

// ViewModel for managing the state and logic of restaurant views
class RestaurantsViewModel: ObservableObject {
   
    @Published var restaurants: [Restaurant] = [] // Published property to store list of restaurants
    private var apiService: APIService = APIService() // Instance of APIService to fetch restaurant data
    private var locationManager = LocationManager()
    private var cancellables: Set<AnyCancellable> = []
    
    private var limiter = APIRateLimiter(interval: 1.0)  // Assuming 1 second between requests

    
    @Published var currentRestaurantIndex = 0 // tracks current index of visible restaurant card
    @Published var radius = 1000 //starting raduis in meters


//    func shouldFetchMoreRestaurants() -> Bool {
//        //to load infinitely
//        return  true
//    }

    //computed property to get current restuarant
    var currentRestaurant: Restaurant? {
        guard currentRestaurantIndex >= 0 && currentRestaurantIndex < restaurants.count else {return nil}
        return restaurants[currentRestaurantIndex]
    }

    init() {
        locationManager.$currentLocation
            .compactMap { $0 } // Only non-nil locations proceed
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.loadRestaurantsIfNeeded()
            }
            .store(in: &cancellables)
    }

    func loadRestaurantsIfNeeded() {
        guard let currentLocation = locationManager.currentLocation else {
            print("Current location is not available.")
            return
        }

//        guard shouldFetchMoreRestaurants() else {
//            print("No need to fetch more restaurants")
//            return
//        }

        fetchRestaurants(currentLocation: currentLocation)
    }

    func fetchRestaurants(currentLocation: CLLocationCoordinate2D) {
        print("Fetching restaurants with radius: \(radius) and offset: \(restaurants.count)")
        apiService.fetchRestaurants(latitude: currentLocation.latitude, longitude: currentLocation.longitude, radius: radius, offset: restaurants.count) { [weak self] newRestaurants in
            guard let self = self else { return }
            guard let newRestaurants = newRestaurants, !newRestaurants.isEmpty else {
                print("No new restaurants found or error fetching restaurants")
                return
            }
            DispatchQueue.main.async {
                self.restaurants.append(contentsOf: newRestaurants)
                print("Restaurants loaded, total now: \(self.restaurants.count)")
                self.radius += 1000
                self.loadRestaurantsIfNeeded()  // Trigger next load if needed
            }
        }
    }



    func loadRestaurants() {
        guard let location = locationManager.currentLocation else {
               print("Current location is not available.")
               return
           }
           
           limiter.perform { [weak self] in
               guard let self = self else { return }
               self.apiService.fetchRestaurants(latitude: location.latitude, longitude: location.longitude, radius: 1000, offset: 100) { newRestaurants in
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
