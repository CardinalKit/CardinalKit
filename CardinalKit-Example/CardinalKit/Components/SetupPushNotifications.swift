//
//  SetupPushNotifications.swift
//  CardinalKit_Example
//
//  Created by Michael Cooper on 2021-03-17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UserNotifications

func SetupPushNotifications() {
    let center = UNUserNotificationCenter.current()
    
    // Request authorization to give push notifications to the user
    center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            print("Success!")
        } else {
            print("Must enable notifications for recurring reminders.")
        }
    }
}

func scheduleNotification() {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "HPDS Survey Reminder"
    content.body = "Now's a great time to take a brief survey for this project!"
    content.categoryIdentifier = "alarm"
    content.sound = UNNotificationSound.default

    var dateComponents = DateComponents()
    dateComponents.hour = 17
    dateComponents.minute = 35
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)
}
