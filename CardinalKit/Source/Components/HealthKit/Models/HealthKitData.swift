//
//  HealthKitData.swift (originally DayData.swift)
//  AstraZeneca
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ObjectMapper

enum HealthKitDataModel : Int {
    case maxNonStopSteps = 0
    case totalSteps 
    case totalFlights
    case distanceWalked
    
    static let all = [maxNonStopSteps, totalSteps, totalFlights, distanceWalked]
}

class HealthKitData: Object, Mappable, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var startDate: String = ""
    @objc dynamic var endDate: String = ""
    @objc dynamic var date: String = ""
    
    @objc dynamic var source: String = ""
    
    @objc dynamic var maxNonStopSteps : Int = -1
    @objc dynamic var totalSteps : Int = -1
    @objc dynamic var totalFlights : Int = -1
    @objc dynamic var distanceWalked : Int = -1
    
    @objc dynamic var passiveWhenCollected : Bool = false
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        date <- map["date"]
        
        source <- map["source"]
        
        maxNonStopSteps <- map["max_non_stop_steps"]
        totalSteps <- map["total_steps"]
        totalFlights <- map["flights_climbed"]
        distanceWalked <- map["distance_walked"]
        
        passiveWhenCollected <- map["passive"]
    }
    
    func store(date: Date) {
        
        self.date = date.localStringFromDate() + "Z" //adding a Z turns this into an ISO date (server marshalling requires the mark). Z means UTC. Would not recommend doing this in any other case. In this it's okay because only the day, month, and year will be kept from the local instance.
        
        self.startDate = date.startOfDay.ISOStringFromDate()
        
        if let endDay = date.endOfDay {
            self.endDate = endDay.ISOStringFromDate()
        }
        
    }
    
    func set(value: Double, usingType type: HealthKitDataModel) {
        switch type {
        case .maxNonStopSteps:
            self.maxNonStopSteps = Int(value)
        case .totalSteps:
            self.totalSteps = Int(value)
        case .totalFlights:
            self.totalFlights = Int(value)
        case .distanceWalked:
            self.distanceWalked = Int(value)
            
        }
    }
    
    func getValue(forType type: HealthKitDataModel) -> Int {
        switch type {
        case .maxNonStopSteps:
            return self.maxNonStopSteps
        case .totalSteps:
            return self.totalSteps
        case .totalFlights:
            return self.totalFlights
        case .distanceWalked:
            return self.distanceWalked
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /*override func isEqual(_ object: HealthKitData?) -> Bool {
        guard let object = object as? HealthKitData else {
            return false
        }
        
        return startDate == object.startDate && endDate == object.endDate && date == object.date && maxNonStopSteps == object.maxNonStopSteps && totalSteps == object.totalSteps && totalFlights == object.totalFlights && distanceWalked == object.distanceWalked
    }*/
    
    static func == (lhs: HealthKitData, rhs: HealthKitData) -> Bool {
        return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate && lhs.date == rhs.date && lhs.maxNonStopSteps == rhs.maxNonStopSteps && lhs.totalSteps == rhs.totalSteps && lhs.totalFlights == rhs.totalFlights && lhs.distanceWalked == rhs.distanceWalked
    }
    
}
