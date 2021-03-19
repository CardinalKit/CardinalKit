//
//  BeaconRanging.swift
//  CardinalKit_Example
//
//  Created by Michael Cooper on 2021-03-18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconRanger: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
    }
    
    func run() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
//        let uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
        let uuid = UUID(uuidString: "62101E0F-1D75-926C-8E39-7BBA7237692D")
        
        let region1 = CLBeaconRegion(uuid: uuid!,
                                        major: 0,
                                        minor: 0,
                                   identifier: "region1")
        
        // beaconRegion -> UUID
        // beaconRegion1
        // beaconRegion2
        
         locationManager.startMonitoring(for: region1)
        // locationManager.startMonitoring(for: beaconRegion1)
        // locationManager.startMonitoring(for: beaconRegion2)
        // locationManager.startRangingBeacons(satisfying: beaconRegion)
        // locationManager.startRangingBeacons(satisfying: beaconRegion1)
        // locationManager.startRangingBeacons(satisfying: beaconRegion2)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        // For logging/debugging
        print(beaconConstraint.uuid)
        
        // any code to upload info to Firestore
        
        // show notif when enter

    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        // exit region of beacon
        
        // showed that notification
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "Entering " + region.identifier
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "EnteringRegion", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        // exit region of beacon
        
        // showed that notification
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "Exiting " + region.identifier
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "ExitingRegion", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}



