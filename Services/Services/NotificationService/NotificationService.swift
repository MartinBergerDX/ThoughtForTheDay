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
    func reschedule()
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
    
    fileprivate func filteredPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        self.notificationCenter!.getPendingNotificationRequests { (pendingNotificationRequests: [UNNotificationRequest]) in
            let filtered = pendingNotificationRequests.filter({ $0.content.categoryIdentifier == QuoteNotificationFactory.categoryIdentifier })
            completionHandler(filtered)
        }
    }
    
    public func scheduleImperialWisdom() {
        filteredPendingNotificationRequests(completionHandler: { [unowned self] (filteredPending: [UNNotificationRequest]) in
            self.scheduledNotificationRequests = filteredPending
            self.scheduleIfNeeded()
        })
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
        let scheduled = QuoteEventDao.init().findAllSortedAscending()
        if (scheduled.count == 0) {
            return
        }
        var remaining = countNotificationsToSchedule()
        while remaining > 0 {
            let date: Date = self.dates.removeFirst()
            for quoteEvent: QuoteEvent in scheduled {
                let quote: String = self.dataProvider.pop()
                let trigger: UNCalendarNotificationTrigger = notificationTrigger(for: date, quoteEvent: quoteEvent)
                let request = self.quoteNotificationFactory.imperialQuote(imperialQuote: quote, trigger: trigger)
                self.schedule(request: request)
                remaining -= 1
                if (remaining == 0) {
                    break
                }
            }
        }
        
        filteredPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            self.printScheduled(requests: requests)
        }
    }
    
    fileprivate func notificationTrigger(for date: Date, quoteEvent: QuoteEvent) -> UNCalendarNotificationTrigger {
        let c = self.requiredComponents()
        var components = Calendar.autoupdatingCurrent.dateComponents(c, from: date)
        components.hour = Int(quoteEvent.hour ?? "0")
        components.minute = Int(quoteEvent.minute ?? "0")
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: false)
        return trigger
    }
    
    fileprivate func loadSomeDates() {
        self.dates.removeAll()
        self.dates.append(self.startDate)
        var components: DateComponents = DateComponents.init()
        components.hour = 0
        components.minute = 0
        var remaining = NotificationService.maxNotifications
        Calendar.autoupdatingCurrent.enumerateDates(startingAfter: self.startDate, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime, using: { (date: Date?, unknown: Bool, stop: inout Bool) in
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
    
    public func reschedule() {
        filteredPendingNotificationRequests { [unowned self] (filteredPending: [UNNotificationRequest]) in
            var identifiers: [String] = []
            for request: UNNotificationRequest in filteredPending {
                let quote: String = request.content.body
                self.dataProvider.push(quote: quote)
                identifiers.append(request.identifier)
            }
            self.notificationCenter?.removePendingNotificationRequests(withIdentifiers: identifiers)
            self.scheduleImperialWisdom()
        }
    }
}

protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
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
