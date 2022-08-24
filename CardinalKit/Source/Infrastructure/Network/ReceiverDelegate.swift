//
//  ReceiverDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol CKReceiverDelegate {
    func request(route: String, onCompletion: @escaping ([String:Any]?) -> Void)
    func requestFromStorage(path:String,url:URL, OnCompletion: @escaping (Bool, Error?) -> Void)
    func requestFilter(route: String, filter:[FilterModel], onCompletion: @escaping ([String:Any]?) -> Void)
    func requestScheduleItems(date: Date, onCompletion: @escaping ([ScheduleModel]) -> Void)
    func requestUrlFromStorage(path:String, onCompletion: @escaping (URL) -> Void, onError: @escaping (Error) -> Void)
    func configure()
}

public class CKReceiver{
    var firebaseManager: FirebaseManager
    init(){
        firebaseManager = FirebaseManager()
    }
}

extension CKReceiver:CKReceiverDelegate{
    public func requestUrlFromStorage(path:String, onCompletion: @escaping (URL) -> Void, onError: @escaping (Error) -> Void){
        firebaseManager.getUrlFileFromStorage(pathFile: path, onCompletion: onCompletion, onError: onError)
    }
    
    public func requestScheduleItems(date: Date, onCompletion: @escaping ([ScheduleModel]) -> Void) {
        let group = DispatchGroup()
        group.enter()
        var itemsResponse:[ScheduleModel] = []
        if let userDataDelegate = CKApp.instance.options.userDataProviderDelegate{
            if let schedulePath =   userDataDelegate.scheduleCollection{
                group.enter()
                 self.fetchCloudScheduleItems(route: schedulePath, date: date){ response in
                    itemsResponse.append(contentsOf: response)
                    DispatchQueue.main.async {
                        group.leave()
                    }
                }
            }
            if let authCollection = userDataDelegate.authCollection{
                let personalCollection = "\(authCollection)schedule"
                group.enter()
                self.fetchCloudScheduleItems(route: personalCollection, date: date){ response in
                    itemsResponse.append(contentsOf: response)
                    DispatchQueue.main.async {
                        group.leave()
                    }
                }
            }
        }
        group.leave()
        group.notify(queue: .main, execute: {
            onCompletion(itemsResponse)
        })
    }
    
    private func fetchCloudScheduleItems(route:String, date:Date, onCompletion: @escaping ([ScheduleModel]) -> Void){
        firebaseManager.getFilterdata(route: route, filter: [
            FilterModel(field:"startTime", filterType:.LessOrEqualTo, value:date)
        ]){ response in
            var itemsResponse:[ScheduleModel] = []
            if let response = response {
                for (_,item) in response{
                    if let item = item as? [String:Any]{
                        if let interval = item["interval"] as? [String:Int],
                           let dayInterval = interval["day"],
                           let startDate = item["startTime"],
                           let startDate = self.firebaseManager.transformTimeStampToDate(timeStamp: startDate)
                        {
                            var valid = true
                            if let endDate = item["endTime"],
                               let endDate = self.firebaseManager.transformTimeStampToDate(timeStamp: endDate),
                               endDate.endOfDay!<=date.startOfDay
                            {
                                valid = false
                            }
                            if valid{
                                let daysDiference = startDate.daysTo(date)
                                if daysDiference % dayInterval == 0 {
                                    if let title = item["title"] as? String,
                                       let instructions = item["instructions"] as? String,
                                       let id = item["id"] as? String,
                                       let type = item["type"] as? String{
                                        if type == "survey",
                                           let surveyId = item["surveyId"] as? String{
                                            itemsResponse.append(ScheduleModel(id: id, title: title, instructions: instructions, type: .survey, surveyId: surveyId, startDate: startDate, endDate: nil, interval: Interval(day: dayInterval)))
                                        }
                                        else{
                                            if let type = ScheduleModelType(rawValue: type){
                                                itemsResponse.append(ScheduleModel(id: id, title: title, instructions: instructions, type: type, surveyId: nil, startDate: startDate, endDate: nil, interval: Interval(day: dayInterval)))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            onCompletion(itemsResponse)
        }
    }
    
    public func requestFilter(route: String, filter: [FilterModel], onCompletion: @escaping ([String : Any]?) -> Void) {
        firebaseManager.getFilterdata(route: route, filter: filter, onCompletion: onCompletion)
    }
    
    public func request(route: String, onCompletion: @escaping ([String:Any]?) -> Void) {
        firebaseManager.get(route: route, onCompletion: onCompletion)
    }
    
    public func requestFromStorage(path:String,url:URL, OnCompletion: @escaping (Bool, Error?) -> Void){
        firebaseManager.getDataFromCloudStorage(path: path, url: url,
                                                OnCompletion: {OnCompletion(true,nil)},
                                                onError: { error in OnCompletion(false,error)}
        )
    }

    
    public func configure() {
        
    }
}
