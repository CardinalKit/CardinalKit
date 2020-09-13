//
//  UIData.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct Notification: Identifiable {
    let id = UUID()
    let testName: String
    let text: String
    let dateSent: Date
    let action: Bool
    
    init(testName: String, text: String, action: Bool) {
        self.testName = testName
        self.text = text
        self.dateSent = Date()
        self.action = action
    }
}

struct Result: Identifiable {
    let id = UUID()
    let testName: String
    let scores: [Any]
}

class NotificationsAndResults: ObservableObject {
    @Published var notifications: [Notification]
    @Published var results: [Result]
    
    init() {
        notifications = [Notification(testName: "Trailmaking B", text: "test is avalible now", action: true), Notification(testName: "Trailmaking A", text: "test can be taken starting 'Date'", action: false), Notification(testName: "Spacital Memory", text: "test is coming up 'Date', please consume a moderate amount of caffine only", action: false), Notification(testName: "Amsler Grid", text: "test is coming up 'Date', please be mindful of eyes usage", action: false)]
        results = [Result(testName: "Trailmaking A", scores: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])]
    }
    
    func getTestIndex(testName: String) -> Int {
        switch testName {
            case "Trailmaking A": return 0
            case "Trailmaking B": return 1
            case "Spatial Memory": return 2
            case "Speech Recognition:": return 3
            case "Amsler Grid": return 4
            default: return 0
        }
    }
}
