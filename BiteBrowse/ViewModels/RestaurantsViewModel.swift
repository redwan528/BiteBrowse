//
//  RestaurantsViewModel.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation
import Combine
import CoreLocation

class RestaurantsViewModel: ObservableObject {
    
    @Published var restaurants: [Restaurant] = []
    private var apiService: APIService = APIService()
    private var locationManager = LocationManager()
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var isLoading = false
    
    @Published var radius = 1000 //starting raduis in meters
    @Published var isEndOfData = false // flag to track if we've reached the end of data
    
    @Published var currentRestaurantIndex = 0 {
        didSet {
            loadRestaurantsIfNeeded()
        }
    }
    
    //computed property to get current restuarant
    var currentRestaurant: Restaurant? {
        guard currentRestaurantIndex >= 0 && currentRestaurantIndex < restaurants.count else {return nil}
        return restaurants[currentRestaurantIndex]
    }
    
    init() {
        locationManager.$currentLocation
            .compactMap { $0 } // only non-nil locations proceed
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.fetchRestaurants(currentLocation: location)
               
            }
            .store(in: &cancellables)
        loadRestaurantsInitially()
        
    }
    private func loadRestaurantsInitially() {
        guard let currentLocation = locationManager.currentLocation else {
            print("Current location is not available at launch.")
            return
        }
        fetchRestaurants(currentLocation: currentLocation)
    }
    
    
    func fetchRestaurants(currentLocation: CLLocationCoordinate2D) {
        isLoading = true
        apiService.fetchRestaurants(latitude: currentLocation.latitude, longitude: currentLocation.longitude, radius: 1000, offset: restaurants.count, limit: 20) { [weak self] newRestaurants in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                guard let newRestaurants = newRestaurants, !newRestaurants.isEmpty else {
                    print("No new restaurants found or error fetching restaurants")
                    return
                }
                self.restaurants.append(contentsOf: newRestaurants)
            }
        }
    }
    
    
    
    func loadRestaurantsIfNeeded() {
        guard let currentLocation = locationManager.currentLocation else {
            print("Current location is not available.")
            return
        }
        
        if currentRestaurantIndex % 20 == 19 || restaurants.count % 20 != 0 {
            print("Attempting to fetch more restaurants due to currentRestaurantIndex: \(currentRestaurantIndex)")
            fetchRestaurants(currentLocation: currentLocation)
        }
    }
    
    
    // moves to the next restaurant in the list
    func showNextRestaurant() {
        if currentRestaurantIndex < restaurants.count - 1 {
            currentRestaurantIndex += 1
            print(currentRestaurantIndex)
        }
    }
    
    // moves to the previous restaurant in the list
    func showPreviousRestaurant() {
        if currentRestaurantIndex > 0 {
            currentRestaurantIndex -= 1
            print(currentRestaurantIndex)
            
        }
    }
    
}
