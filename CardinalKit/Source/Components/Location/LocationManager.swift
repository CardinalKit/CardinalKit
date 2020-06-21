//
//  LocationManager.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 4/25/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import CoreLocation

struct LocationData {
    var deltaLatitude: Double
    var deltaLongitude: Double
    var distance: Double
    var angle: Double
    var altitude: Double
    var timestamp: Date
    var horizontalAccuracy: Double
    var vertialAccuracy: Double
    var course: Double
    var speed: Double
    var floor: Int?
}

protocol LocationManagerDelegate: class {
    func broadcast(_ locationData: LocationData)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    fileprivate var locationManager: CLLocationManager
    fileprivate var delegates = [LocationManagerDelegate]() //SANTI: used post 2.3.3, migrate to this if needed. Allows the same class to have multiple delegates listening for location data
    
    var delegate: ((LocationData) -> Void)? = nil //OLD implementation. JeongWoo. In-use by MotionController, and by startCollecting:onCompletion.
    
    fileprivate var previousLocation: CLLocation? = nil
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.showsBackgroundLocationIndicator = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation //or kCLLocationAccuracyBest
        
        super.init()
        
        locationManager.delegate = self
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func addDelegate(_ delegate: LocationManagerDelegate) {
        if let _ = delegates.index(where: { $0 === delegate }) {
            return
        }
        
        delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: LocationManagerDelegate) {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        let locationData = getLocationData(with: location)
        previousLocation = location
        fireDelegates(locationData)
    }
    
    fileprivate func fireDelegates(_ locationData: LocationData) {
        self.delegate?(locationData)
        for delegate in delegates {
            delegate.broadcast(locationData)
        }
    }
    
    // main logic to get detailed location information
    fileprivate func getLocationData(with location: CLLocation) -> LocationData {
        var deltaLatitude: Double = 0
        var deltaLongitude: Double = 0
        var distance: Double = 0
        var angle: Double = 0
        
        if let previousLocation = previousLocation {
            deltaLatitude = location.coordinate.latitude - previousLocation.coordinate.latitude
            deltaLongitude = location.coordinate.longitude - previousLocation.coordinate.longitude
            distance = location.distance(from: previousLocation) // uses Swift built-in distance func
            angle = getAngle(deltaLon: deltaLongitude, deltaLat: deltaLatitude)
        }
        
        let locationData = LocationData(deltaLatitude: deltaLatitude,
                                        deltaLongitude: deltaLongitude,
                                        distance: distance,
                                        angle: angle,
                                        altitude: location.altitude,
                                        timestamp: location.timestamp,
                                        horizontalAccuracy: location.horizontalAccuracy,
                                        vertialAccuracy: location.verticalAccuracy,
                                        course: location.course,
                                        speed: location.speed,
                                        floor: location.floor?.level)
        
        
        return locationData
    }
    
    fileprivate func getAngle(deltaLon: Double, deltaLat: Double) -> Double {
        return atan(deltaLon / deltaLat)
    }
    
    func startCollecting(onCompletion: @escaping (_ locationData: LocationData) -> Void) {
        self.delegate = onCompletion
    }
    
    func stopCollecting() {
        self.delegate = nil
    }
    
}
