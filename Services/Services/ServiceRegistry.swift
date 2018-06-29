//
//  ServiceRegistry.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/14/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
import UserNotifications

public struct Constants {
    public static let fileName = "Quotes"
}

public protocol ServiceRegistryProtocol {
    var notification: TDNotificationServiceProtocol { get }
    var update: UpdateServiceProtocol { get }
    var database: DatabaseProtocol { get }
}

public class ServiceRegistry: NSObject, ServiceRegistryProtocol {
    public static let shared: ServiceRegistryProtocol = ServiceRegistry()
    public var notification: TDNotificationServiceProtocol = NotificationService.null
    public var update: UpdateServiceProtocol = UpdateService.null
    public var database: DatabaseProtocol = CoreDataStack.null
    
    override init() {
        self.notification = NotificationService(quoteDataProvider: QuoteDataProvider.init(textFileName: Constants.fileName), notificationCenter: UNUserNotificationCenter.current())
        self.update = UpdateService.init()
        self.database = CoreDataStack.init(modelName: CoreDataStack.defaultModelName)
    }
}
