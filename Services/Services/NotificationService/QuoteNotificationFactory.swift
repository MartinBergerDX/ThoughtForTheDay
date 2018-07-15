//
//  QuoteNotificationFactory.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/15/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UserNotifications

class QuoteNotificationFactory {
    internal static let categoryIdentifier = "ImperialQuote"
    internal static let title: String = "Imperial Wisdom for this Holy Day"
    
    func imperialQuote(imperialQuote: String, trigger: UNCalendarNotificationTrigger) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = QuoteNotificationFactory.title
        content.body = imperialQuote
        content.sound = nil
        content.categoryIdentifier = QuoteNotificationFactory.categoryIdentifier
        let request = UNNotificationRequest(identifier: imperialQuote, content: content, trigger: trigger)
        return request
    }
}
