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
    func register()
}

class NotificationService: NSObject, TDNotificationServiceProtocol {
    static var null: TDNotificationServiceProtocol = NotificationService()
    var dataProvider: RandomQuoteDataProviderProtocol = QuoteDataProvider.null
    var notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()
    static let maxNotifications: Int = 64
    fileprivate static let hour = 14
    fileprivate static let minute = 00
    
    override init() {
        
    }
    
    init(quoteDataProvider: RandomQuoteDataProviderProtocol, notificationCenter: UserNotificationCenterProtocol) {
        super.init()
        self.dataProvider = quoteDataProvider
        self.notificationCenter = notificationCenter
    }
    
    func scheduleImperialWisdom() {
        self.notificationCenter.getPendingNotificationRequests { [unowned self] (pendingNotificationRequests: [UNNotificationRequest]) in
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
        components.hour = NotificationService.hour
        components.minute = NotificationService.minute
        if let nextDate = Calendar.autoupdatingCurrent.nextDate(after: date, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime) {
            return nextDate
        }
        return today
    }
    
    func scheduleNotifications(startDate: Date, remaining: inout Int) {
        var dates: [Date] = []
        var components: DateComponents = DateComponents.init()
        components.hour = NotificationService.hour
        components.minute = NotificationService.minute
        Calendar.autoupdatingCurrent.enumerateDates(startingAfter: startDate, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime, using: { (date: Date?, unknown: Bool, stop: inout Bool) in
            guard let theDate = date else {
                return
            }
            dates.append(theDate)
            remaining -= 1
            if (remaining == 0) {
                stop = true
            }
        })
        
        let factory = QuoteNotificationFactory.init()
        for date: Date in dates {
            let quote: String = self.dataProvider.popRandomQuote()
            let c = self.requiredComponents()
            var components = Calendar.autoupdatingCurrent.dateComponents(c, from: date)
            components.hour = NotificationService.hour
            components.minute = NotificationService.minute
            let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: false)
            let request = factory.imperialQuote(imperialQuote: quote, trigger: trigger)
            self.schedule(request: request)
        }
    }
    
    func requiredComponents() -> Set<Calendar.Component> {
        return Set<Calendar.Component>.init(arrayLiteral: Calendar.Component.year, Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute)
    }
    
    func schedule(request: UNNotificationRequest) {
        self.notificationCenter.add(request) { (error : Error?) in
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
    
    func register() {
        if let nc = self.notificationCenter as? UNUserNotificationCenter {
            nc.delegate = self
        }
        
        let options: UNAuthorizationOptions = [.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted: Bool, error: Error?) in
            if granted == false {
                print("Failed to register local notifications.")
            }
        }
    }
}

protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {
    
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification: " + notification.request.content.body)
        completionHandler(.alert)
    }
}
