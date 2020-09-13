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
    let text: String
    let dateSent: Date
    let action: Bool
    
    init(text: String, action: Bool) {
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
        notifications = [Notification(text: "Hi this is a test", action: true)]
        results = [Result(testName: "Trailmaking A", scores: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])]
    }
}
