//
//  NotificationService.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/13/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UserNotifications

protocol TDNotificationServiceProtocol {
    func scheduleImperialWisdom()
}

class NotificationService: TDNotificationServiceProtocol {
    static var null: TDNotificationServiceProtocol = NotificationService()
    var dataProvider: RandomQuoteDataProviderProtocol = QuoteDataProvider.null
    var notificationCentar: UserNotificationCenterProtocol = UNUserNotificationCenter.current()
    static let maxNotifications: Int = 64
    
    init () {
        
    }
    
    init(quoteDataProvider: RandomQuoteDataProviderProtocol, notificationCenter: UserNotificationCenterProtocol) {
        self.dataProvider = quoteDataProvider
        self.notificationCentar = notificationCenter
    }
    
    func scheduleImperialWisdom() {
        self.notificationCentar.getPendingNotificationRequests { [unowned self] (pendingNotificationRequests: [UNNotificationRequest]) in
            self.process(pendingNotificationRequests: pendingNotificationRequests)
        }
    }
    
    fileprivate func process(pendingNotificationRequests: [UNNotificationRequest]) {
        // filter by category
        let pending = pendingNotificationRequests.filter({ $0.content.categoryIdentifier == QuoteNotificationFactory.categoryIdentifier })
        printScheduled(requests: pending)
        var remaining: Int = NotificationService.maxNotifications - pending.count
        if remaining == 0 {
            print("Max amount of notifications scheduled: \(NotificationService.maxNotifications), so no new notifications will be scheduled now.")
            return
        }
        var startDate: Date = Date.init()
        if (remaining != NotificationService.maxNotifications) {
            if let request: UNNotificationRequest = pending.last {
                startDate = nextDate(request: request)
            }
        }
        self.scheduleNotifications(startDate: startDate, remaining: &remaining)
    }
    
    fileprivate func nextDate(request: UNNotificationRequest) -> Date {
        let today = Date.init()
        guard let trigger: UNCalendarNotificationTrigger = request.trigger as? UNCalendarNotificationTrigger else {
            return today
        }
        guard let date = Calendar.autoupdatingCurrent.date(from: trigger.dateComponents) else {
            return today
        }
        var components = DateComponents.init()
        components.hour = 14
        if let nextDate = Calendar.autoupdatingCurrent.nextDate(after: date, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime) {
            return nextDate
        }
        return today
    }
    
    func scheduleNotifications(startDate: Date, remaining: inout Int) {
        var dates: [Date] = []
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents.hour = 14
        Calendar.autoupdatingCurrent.enumerateDates(startingAfter: startDate, matching: dateComponents, matchingPolicy: Calendar.MatchingPolicy.nextTime, using: { (date: Date?, unknown: Bool, stop: inout Bool) in
            guard let theDate = date else {
                return
            }
            dates.append(theDate)
            remaining -= 1
            if (remaining == 0) {
                stop = true
            }
        })
        
        for date: Date in dates {
            let quote: String = self.dataProvider.popRandomQuote()
            let c = self.requiredComponents()
            let dateComponents = Calendar.autoupdatingCurrent.dateComponents(c, from: date)
            let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
            let request = QuoteNotificationFactory.init().imperialQuote(imperialQuote: quote, trigger: trigger)
            self.schedule(request: request)
        }
    }
    
    func requiredComponents() -> Set<Calendar.Component> {
        return Set<Calendar.Component>.init(arrayLiteral: Calendar.Component.year, Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute)
    }
    
    func schedule(request: UNNotificationRequest) {
        self.notificationCentar.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func printScheduled(requests: [UNNotificationRequest]) {
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        for request: UNNotificationRequest in requests {
            guard let trigger: UNCalendarNotificationTrigger = request.trigger as? UNCalendarNotificationTrigger else {
                return
            }
            guard let date = Calendar.autoupdatingCurrent.date(from: trigger.dateComponents) else {
                return
            }
            print(dateFormatter.string(from: date) + " " + request.content.body)
        }
    }
}

protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

extension UNUserNotificationCenter : UserNotificationCenterProtocol {
    
}
