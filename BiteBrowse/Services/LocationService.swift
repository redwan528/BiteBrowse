//
//  LocationService.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()  // Core Location manager object
    @Published var currentLocation: CLLocationCoordinate2D? // published property to store the current location

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //setting location accuracy
        self.locationManager.requestWhenInUseAuthorization() //requesting location permission
        self.locationManager.startUpdatingLocation() //start updating location
    }

    // Delegate method called when new locations are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }

    // Delegate method called when there is an error with location updates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
