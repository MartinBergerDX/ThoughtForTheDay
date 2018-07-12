//
//  NotificationService.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/13/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

public protocol TDNotificationServiceProtocol {
    func scheduleImperialWisdom()
    func register()
}

class NotificationService: NSObject, TDNotificationServiceProtocol {
    static let maxNotifications: Int = 64
    static var null: TDNotificationServiceProtocol = NotificationService()

    var dataProvider: RandomQuoteDataProviderProtocol = QuoteDataProvider.null
    var notificationCenter: UserNotificationCenterProtocol?
    var logger: FileLogger = FileLogger.logger
    
    fileprivate var scheduledNotificationRequests: [UNNotificationRequest] = []
    fileprivate var dates: [Date] = []
    fileprivate var startDate: Date = Date.init()
    fileprivate let quoteNotificationFactory = QuoteNotificationFactory.init()
    
    override init() {
        
    }
    
    init(quoteDataProvider: RandomQuoteDataProviderProtocol, notificationCenter: UserNotificationCenterProtocol) {
        super.init()
        self.dataProvider = quoteDataProvider
        self.notificationCenter = notificationCenter
    }
    
    public func scheduleImperialWisdom() {
        self.notificationCenter!.getPendingNotificationRequests { [unowned self] (pendingNotificationRequests: [UNNotificationRequest]) in
            self.scheduledNotificationRequests = pendingNotificationRequests.filter({ $0.content.categoryIdentifier == QuoteNotificationFactory.categoryIdentifier })
            self.scheduleIfNeeded()
        }
    }
    
    fileprivate func scheduleIfNeeded() {
        if (maxNotificationsScheduled()) {
            print("Max notifications scheduled.")
            return
        }
        self.startDate = Date.init()
        if let request: UNNotificationRequest = self.scheduledNotificationRequests.last {
            self.startDate = nextDate(request: request)
        }
        self.scheduleNotifications()
    }
    
    fileprivate func maxNotificationsScheduled() -> Bool {
        let pending = self.scheduledNotificationRequests
        printScheduled(requests: pending)
        let remaining: Int = NotificationService.maxNotifications - pending.count
        return remaining == 0
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
        components.hour = 0
        if let nextDate = Calendar.autoupdatingCurrent.nextDate(after: date, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime) {
            return nextDate
        }
        return today
    }
    
    fileprivate func scheduleNotifications() {
        loadSomeDates()
        let scheduledTimestamps = SchedulingTimestampDao.init().findAllSortedAscending()
        var remainingToSchedule = countNotificationsToSchedule()
        while remainingToSchedule > 0 {
            let date: Date = self.dates.removeFirst()
            for timestamp: SchedulingTimestamp in scheduledTimestamps {
                let quote: String = self.dataProvider.popRandomQuote()
                let trigger: UNCalendarNotificationTrigger = notificationTrigger(for: date, timestamp: timestamp)
                let request = self.quoteNotificationFactory.imperialQuote(imperialQuote: quote, trigger: trigger)
                self.schedule(request: request)
                remainingToSchedule -= 1
                if (remainingToSchedule == 0) {
                    break
                }
            }
        }
    }
    
    fileprivate func notificationTrigger(for date: Date, timestamp: SchedulingTimestamp) -> UNCalendarNotificationTrigger {
        let c = self.requiredComponents()
        var components = Calendar.autoupdatingCurrent.dateComponents(c, from: date)
        components.hour = Int(timestamp.hour ?? "0")
        components.minute = Int(timestamp.minute ?? "0")
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: false)
        return trigger
    }
    
    fileprivate func loadSomeDates() {
        self.dates = []
        var components: DateComponents = DateComponents.init()
        components.hour = 0
        var remaining = NotificationService.maxNotifications
        Calendar.autoupdatingCurrent.enumerateDates(startingAfter: startDate, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime, using: { (date: Date?, unknown: Bool, stop: inout Bool) in
            guard let theDate = date else {
                return
            }
            dates.append(theDate)
            remaining -= 1
            stop = (remaining == 0)
        })
    }
    
    fileprivate func countNotificationsToSchedule() -> Int {
        return NotificationService.maxNotifications - self.scheduledNotificationRequests.count
    }
    
    fileprivate func requiredComponents() -> Set<Calendar.Component> {
        return Set<Calendar.Component>.init(arrayLiteral: Calendar.Component.year, Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute)
    }
    
    fileprivate func schedule(request: UNNotificationRequest) {
        self.notificationCenter!.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    fileprivate func printScheduled(requests: [UNNotificationRequest]) {
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
    
    public func register() {
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
        let log: String = "Received local notification: " + notification.request.content.body
        print(log)
        print(log, to: &self.logger)
        completionHandler(.alert)
    }
}
