//
//  LocationManager.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 26/09/2021.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    @Published var currentRegion: MKCoordinateRegion = .init()
    
    override init(){
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        
        checkStatus(status: manager.authorizationStatus)
    }
    
    private func checkStatus(status: CLAuthorizationStatus){
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            return
        case .denied, .notDetermined, .restricted:
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
            return
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        self.currentLocation = location
        self.currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500)
    }
}
