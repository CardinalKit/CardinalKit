//
//  OHMSerializer.swift
//  abseil
//
//  Created by Esteban Ramos on 17/04/22.
//

import Foundation
import HealthKit

protocol OpenMHSerializer {
    func json(for sample: [HKSample]) throws -> [[String: Any]]
}

// Transform the healthkit data into a json with the openMHealth format
// cardinalkit uses granola for this
class CKOpenMHSerializer: OpenMHSerializer{
    // use granola as serializer
    let serializer = OMHSerializer()
    
    /**
     receives an array of samples from healthkit HkSample and returns a json in openMhealth format
     */
    func json(for data: [HKSample]) throws -> [[String: Any]]{
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var samplesArray = [[String: Any]]()
        try samplesArray = data.map({
            let sampleInJsonString = try serializer.json(for: $0)
            let sampleInData = Data(sampleInJsonString.utf8)
            let sampleInObject = try JSONSerialization.jsonObject(with: sampleInData, options: []) as? [String: Any]
            return sampleInObject!
        })
        
        return JoinData(data: samplesArray)
        
    }
    
    //Join data of the same type to send fewer records
    func JoinData(data: [[String: Any]])->[[String: Any]]{
        let firstElement = data.first
        if let element = firstElement,
           let body = element["body"] as? [String: Any]
        {
            if let quantityType = body["quantity_type"] as? String{
                switch(quantityType){
                case "HKQuantityTypeIdentifierStepCount":
                    return joinDataStepCount(data: data)
                case "HKQuantityTypeIdentifierActiveEnergyBurned":
                    return joinDataEnergyBurned(data: data)
                default:
                    return data
                }
            }
        }
        return data
    }
    
    private func joinDataEnergyBurned(data: [[String:Any]])->[[String:Any]]{
        var finalData = [[String: Any]]()
        var datesDictionary = [Date:[String:Any]]()
        var firstElement = data.first!
        var body = firstElement["body"] as! [String: Any]
        if var kcalBurned = body["kcal_burned"] as? [String:Any]{
            for element in data {
                if let nBody = element["body"] as? [String:Any],
                   let kcal = nBody["kcal_burned"] as? [String:Any],
                   let kcalValue = kcal["value"] as? Int {
                    if let time_frame = nBody["effective_time_frame"] as? [String:Any],
                       let dateStr = time_frame["date_time"] as? String{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
                        let date = dateFormatter.date(from: dateStr)!
                        let onlyDate = removeTimeStamp(fromDate: date)
                        var finalKcalValue = kcalValue
                        if let dateKcalValue = datesDictionary[onlyDate]{
                            finalKcalValue+=dateKcalValue["count"] as! Int
                        }
                        else{
                            datesDictionary[onlyDate]=[String:Any]()
                            datesDictionary[onlyDate]?["date"] = dateStr
                        }
                        datesDictionary[onlyDate]?["count"]=finalKcalValue
                    }
                }
            }
            for dateElement in datesDictionary{
                kcalBurned["value"] = dateElement.value["count"]
                body["kcal_burned"] = kcalBurned
                body["effective_time_frame"] = ["date_time":dateElement.value["date"]]
                firstElement["body"]=body
                finalData.append(firstElement)
            }
            return finalData
        }
        else{
            return data
        }
    }
    
    private func joinDataStepCount(data: [[String: Any]])->[[String: Any]]{
        var finalData = [[String: Any]]()
        var datesDictionary = [Date:[String:Any]]()
        var firstElement = data.first!
        var body = firstElement["body"] as! [String: Any]
        
        for element in data {
            if let nBody = element["body"] as? [String:Any],
               let count = nBody["step_count"] as? Int{
                if let time_frame = nBody["effective_time_frame"] as? [String:Any]{
                    var dateString:String? = nil
                    if let dateInterval = time_frame["time_interval"] as? [String:Any],
                    let dateStr = dateInterval["start_date_time"] as? String{
                        dateString = dateStr
                    }
                
                  if let dateStr = time_frame["date_time"] as? String{
                      dateString = dateStr
                  }
                    
                    if let dateStr = dateString{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
                        let date = dateFormatter.date(from: dateStr)!
                        let onlyDate = removeTimeStamp(fromDate: date)
                        var finalStepCount = count
                        if let dateStepCount = datesDictionary[onlyDate]{
                            finalStepCount+=dateStepCount["count"] as! Int
                        }
                        else{
                            datesDictionary[onlyDate]=[String:Any]()
                            datesDictionary[onlyDate]?["date"] = dateStr
                        }
                        datesDictionary[onlyDate]?["count"]=finalStepCount
                    }
                }
            }
        }
        for dateElement in datesDictionary{
            body["step_count"] = dateElement.value["count"]
            body["effective_time_frame"] = ["date_time":dateElement.value["date"]]
            firstElement["body"]=body
            finalData.append(firstElement)
        }
        return finalData
    }
    
    private func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    
}
