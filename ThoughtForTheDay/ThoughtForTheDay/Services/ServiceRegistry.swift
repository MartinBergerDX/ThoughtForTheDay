//
//  ServiceRegistry.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/14/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
import UserNotifications

struct Constants {
    static let fileName = "Quotes"
}

protocol ServiceRegistryProtocol {
    var notification: TDNotificationServiceProtocol { get }
    var update: UpdateServiceProtocol { get }
}

class ServiceRegistry: NSObject, ServiceRegistryProtocol {
    static let shared: ServiceRegistryProtocol = ServiceRegistry()
    var notification: TDNotificationServiceProtocol = NotificationService.null
    var update: UpdateServiceProtocol = UpdateService.null
    
    override init() {
        self.notification = NotificationService(quoteDataProvider: QuoteDataProvider.init(textFileName: Constants.fileName), notificationCenter: UNUserNotificationCenter.current())
        self.update = UpdateService.init()
    }
}
