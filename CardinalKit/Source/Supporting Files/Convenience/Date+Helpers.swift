//
//  Date+Helpers.swift
//  CS342Support
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation

extension Date {
    
    public func fullFormattedString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
    }
    
    public func shortFormattedString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }
    
    public var yesterday: Date {
        return dayByAdding(-1) ?? Date().addingTimeInterval(-86400)
    }
    
    public var tomorrow: Date {
        return dayByAdding(1) ?? Date().addingTimeInterval(86400)
    }
    
    public var startOfDay: Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        return cal.startOfDay(for: self)
    }
    
    public var endOfDay: Date? {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        guard let startOfDay = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return (calendar as NSCalendar).date(byAdding: .day, value: 1, to: startOfDay, options: [])
    }
    
    public func ISOStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.string(from: self) + "Z" //this is in UTC, 0 seconds from GMT.
    }
    
    public func shortStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.string(from: self)
    }
    
    public func dayByAdding(_ daysToAdd: Int) -> Date? {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        guard let startOfDay = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return (calendar as NSCalendar).date(byAdding: .day, value: daysToAdd, to: startOfDay, options: [])
    }
    
}

extension Date {
    fileprivate static func componentFlags() -> NSCalendar.Unit { return [.year, .month, .day, .weekday] }
    
    static func getTodayHour() -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (calendar as NSCalendar).components([.hour, .minute], from: Date())
        let hour = components.hour ?? 0
        let minutes = components.minute ?? 0
        return "Today, \(hour):\(minutes)"
    }
    
    func getDay() -> Int {
        let formatter  = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (calendar as NSCalendar).components(Date.componentFlags(), from: self)
        let day = components.day
        return day!
    }
    
    func getMonth() -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (calendar as NSCalendar).components(Date.componentFlags(), from: self)
        let month = formatter.shortMonthSymbols[components.month!-1]
        return month
    }
    
    func timeToString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    func longFormattedString(includeTime: Bool = false) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: includeTime ? .long : .none)
    }
    
    static func dateFromComponents(_ components: DateComponents) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        return calendar.date(from: components)
    }
    
    static func dateFromString(_ string: String) -> Date?  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SSS"
        
        if let stringDate = dateFormatter.date(from: string) {
            return stringDate
        } else {
            return nil
        }
    }
    
    //returns a string with a specific format, conforming to UTC
    func stringWithFormat(_ format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS") -> String {
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.string(from: self)
    }
    
    //returns a string with ISO format conforming to local timezone.
    func localStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: self)
    }
    
    static func dateFromISOString(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        
        if let stringDate = dateFormatter.date(from: string) {
            return stringDate
        } else {
            return nil
        }
    }
    
    public func isLessThanOneMinute(_ dateToCompare: Date) -> Bool {
        if abs(self.minutesFrom(dateToCompare)) < 1 {
            return true
        }
        return false
    }
    
    func minutesFrom(_ dateToCompare: Date) -> Int {
        return (Calendar.current as NSCalendar).components([.minute], from: dateToCompare, to: self, options: []).minute!
    }
    
    func daysTo(_ dateToCompare: Date) -> Int {
        return (Calendar.current as NSCalendar).components([.day], from: self, to: dateToCompare, options: []).day!
    }
    
    func monthByAdding(_ monthsToAdd: Int) -> Date? {
        let calendar = Calendar.current
        return (calendar as NSCalendar).date(byAdding: .month, value: monthsToAdd, to: self, options: [])
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current;
        let components = (calendar as NSCalendar).components([.year, .month], from: self);
        
        guard let startOfMonth = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        
        return startOfMonth;
    }
    
    func endOfMonth() -> Date? {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: self)
        
        guard let startOfMonth = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return (calendar as NSCalendar).date(byAdding: .month, value: 1, to: startOfMonth, options: [])
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}
