//
//  ScheduleModel.swift
//  abseil
//
//  Created by Esteban Ramos on 7/07/22.
//

import Foundation

public enum ScheduleModelType : String{
    case steps = "steps"
    case survey = "survey"
    case coffeTask = "coffeTask"
    case doxylamineTask = "doxylamineTask"
    case nauseaTask = "nauseaTask"
}

public struct Interval{
    var day: Int?
    var week: Int?
    var month: Int?
    var year: Int?
    
    public init(){
        
    }
    
    public init(day:Int){
        self.day = day
    }
    
    public init(week:Int){
        self.week = week
    }
    
    public init(month:Int){
        self.month = month
    }
    
    public init(year:Int){
        self.year = year
    }
    
    func transformOnDict() -> [String:Any]{
        return [
            "day":self.day ?? ""
        ]
    }
}

public struct ScheduleModel{
    public let title:String
    public let instructions:String
    public let id:String
    public let type:ScheduleModelType
    public let surveyId:String?
    public let startDate: Date
    public let endDate: Date?
    public let interval: Interval
    
    public init(id: String, title:String, instructions:String, type: ScheduleModelType, surveyId:String?, startDate:Date, endDate: Date?, interval:Interval){
        self.id = id
        self.title = title
        self.instructions = instructions
        self.type = type
        self.surveyId = surveyId
        self.startDate = startDate
        self.endDate = endDate
        self.interval = interval
    }
    
    public func transformOnDict() -> [String:Any]{
        let dictionary:[String:Any] = [
            "id":self.id,
            "title":self.title,
            "instructions":self.instructions,
            "type": self.type.rawValue,
            "surveyId" : self.surveyId ?? "",
            "startTime" :  FirebaseManager.transformDateToTimeStamp(date: self.startDate),
            "endTime" : FirebaseManager.transformDateToTimeStamp(date: self.endDate),
            "interval" : self.interval.transformOnDict()
        ]
        return dictionary
    }
}
