//
//  MockUserNotificationCenter.swift
//  ThoughtForTheDayTests
//
//  Created by Martin on 6/16/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
import UserNotifications
@testable import Services

class MockUserNotificationCenter: NSObject, UserNotificationCenterProtocol {
    fileprivate var requests: [UNNotificationRequest] = []
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(self.requests)
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        self.requests.append(request)
        completionHandler?(nil)
    }
    
    func count() -> Int {
        return self.requests.count
    }
    
    func fire(notifications amount: Int) {
        for _ in 0 ..< amount {
            self.requests.removeFirst()
        }
    }
    
    func validateDates() -> Bool {
        var dates: [Date] = []
        for request: UNNotificationRequest in self.requests {
            if let trigger: UNCalendarNotificationTrigger = request.trigger as? UNCalendarNotificationTrigger {
                if let date: Date = Calendar.autoupdatingCurrent.date(from: trigger.dateComponents) {
                    dates.append(date)
                } else {
                    return false
                }
            }
        }
        if (dates.count == 0) {
            return true
        }
        
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        
        for i: Int in 0 ..< dates.count - 1 {
            let d1 = dates[i]
            let d2 = dates[i + 1]
            if d1 > d2 {
                return false
            }
            let c1: DateComponents = Calendar.autoupdatingCurrent.dateComponents(dateComponents(), from: d1)
            let c2: DateComponents = Calendar.autoupdatingCurrent.dateComponents(dateComponents(), from: d2)
            print(dateFormatter.string(from: d1) + " " + dateFormatter.string(from: d2))
            if c1.day == c2.day && c1.month == c2.month && c1.hour == c2.hour && c1.minute == c2.minute {
                return false
            }
        }
        return true
    }
    
    fileprivate func dateComponents() -> Set<Calendar.Component> {
        return Set<Calendar.Component>.init(arrayLiteral: Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute)
    }
}
