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
    @Published var permissionDenied = false // tracks if location permission is denied
    
    override init() {
        super.init()
        checkLocationAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //setting location accuracy
        self.locationManager.requestWhenInUseAuthorization() //requesting location permission
        self.locationManager.startUpdatingLocation() //start updating location
       
        
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    // Delegate method called when new locations are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("Failed to get a valid location")
            return
        }
        currentLocation = location.coordinate
        //print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    
    // Handles changes in location permissions.
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if status == .denied || status == .restricted {
               print("Location has been permission denied.")
               permissionDenied = true // Update observable to reflect permission denial.
           } else {
               permissionDenied = false
               locationManager.startUpdatingLocation() // restart location updates if permission is granted
           }
       }
    
   
    // check and request location authorization based on status
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location permission denied.")
            permissionDenied = true
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

}
