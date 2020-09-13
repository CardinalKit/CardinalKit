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
    let dateSent = Date()
    let testName: String
    let text: String
    let action: Bool
}

struct Result: Identifiable {
    let id = UUID()
    let testName: String
    let scores: [Int]
}

class NotificationsAndResults: ObservableObject {
    @Published var currNotifications: [Notification]
    @Published var upcomingNotifications: [Notification]
    @Published var results: [Result]
    
    init() {
        currNotifications = [
            Notification(testName: "Trailmaking B", text: "test is avalible now", action: true)
        ]
        upcomingNotifications = [
            Notification(testName: "Trailmaking A", text: "test can be taken starting 'Date'", action: false),
            Notification(testName: "Spatial Memory", text: "test is coming up 'Date', please consume a moderate amount of caffine only", action: false),
            Notification(testName: "Amsler Grid", text: "test is coming up 'Date', please be mindful of eyes usage", action: false)
        ]
        results = [
            Result(testName: "Trailmaking A", scores: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        ]
    }
    
    func getTestIndex(testName: String) -> Int {
        switch testName {
            case "Trailmaking A": return 1
            case "Trailmaking B": return 2
            case "Spatial Memory": return 3
            case "Speech Recognition:": return 4
            case "Amsler Grid": return 5
            default:
                fatalError("Unrecognized test \(testName)")
        }
    }
    
    func getLastestScore(scores: [Int]) -> Int {
        return scores[0] // change based on the method used to sort the scores array by time (old->new OR new-> old)
    }
}
