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
    case MSWS = 0
    case steps
    case flightsClimbed
    case distance
    
    static let all = [MSWS, steps, flightsClimbed, distance]
}

class HealthKitData: Object, Mappable, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var startDate: String = ""
    @objc dynamic var endDate: String = ""
    @objc dynamic var date: String = ""
    
    @objc dynamic var source: String = ""
    
    @objc dynamic var MSWS : Int = -1
    @objc dynamic var steps : Int = -1
    @objc dynamic var flightsClimbed : Int = -1
    @objc dynamic var distance : Int = -1
    
    @objc dynamic var passiveWhenCollected : Bool = false
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        date <- map["date"]
        
        source <- map["source"]
        
        MSWS <- map["MSWS"]
        steps <- map["steps"]
        flightsClimbed <- map["flights_climbed"]
        distance <- map["distance"]
        
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
        case .MSWS:
            self.MSWS = Int(value)
        case .steps:
            self.steps = Int(value)
        case .flightsClimbed:
            self.flightsClimbed = Int(value)
        case .distance:
            self.distance = Int(value)
            
        }
    }
    
    func getValue(forType type: HealthKitDataModel) -> Int {
        switch type {
        case .MSWS:
            return self.MSWS
        case .steps:
            return self.steps
        case .flightsClimbed:
            return self.flightsClimbed
        case .distance:
            return self.distance
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
        return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate && lhs.date == rhs.date && lhs.MSWS == rhs.MSWS && lhs.steps == rhs.steps && lhs.flightsClimbed == rhs.flightsClimbed && lhs.distance == rhs.distance
    }
    
}
