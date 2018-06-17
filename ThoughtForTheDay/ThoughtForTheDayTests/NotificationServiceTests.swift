//
//  ThoughtForTheDayTests.swift
//  ThoughtForTheDayTests
//
//  Created by Martin on 6/13/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import XCTest
import UserNotifications

class NotificationServiceTests: XCTestCase {
    var notificationService: TDNotificationServiceProtocol = NotificationService.null
    var notificationCenter = MockUserNotificationCenter()
    
    override func setUp() {
        super.setUp()
        let dataProvider = MockRandomQuoteDataProvider.init()
        self.notificationCenter = MockUserNotificationCenter()
        self.notificationService = NotificationService.init(quoteDataProvider: dataProvider, notificationCenter: self.notificationCenter)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func scheduleAll() {
        self.notificationCenter.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            if (requests.count == 0) {
                self.notificationService.scheduleImperialWisdom()
            }
        }
    }
    
    func testScheduleAll() {
        scheduleAll()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
    }
    
    func testScheduleAllFire20Schedule20() {
        let count: Int = 20
        scheduleAll()
        self.notificationCenter.fire(notifications: count)
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications - count)
        self.notificationService.scheduleImperialWisdom()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
    }
    
    func testScheduleComplex1() {
        let count: Int = 10
        scheduleAll()
        
        self.notificationCenter.fire(notifications: count)
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications - count)
        XCTAssert(self.notificationCenter.validateDates())
        
        self.notificationService.scheduleImperialWisdom()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
        XCTAssert(self.notificationCenter.validateDates())
        
        self.notificationCenter.fire(notifications: count)
        self.notificationService.scheduleImperialWisdom()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
        XCTAssert(self.notificationCenter.validateDates())
    }
    
    func testScheduleComplex2() {
        let count: Int = 10
        scheduleAll()
        
        self.notificationCenter.fire(notifications: NotificationService.maxNotifications)
        XCTAssert(self.notificationCenter.count() == 0)
        XCTAssert(self.notificationCenter.validateDates())
        
        self.notificationService.scheduleImperialWisdom()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
        XCTAssert(self.notificationCenter.validateDates())
        
        self.notificationCenter.fire(notifications: count)
        self.notificationService.scheduleImperialWisdom()
        XCTAssert(self.notificationCenter.count() == NotificationService.maxNotifications)
        XCTAssert(self.notificationCenter.validateDates())
    }
    
    func testDateProviderReloads() {
        let dataProvider = QuoteDataProvider.init(textFileName: Constants.fileName)
        self.notificationService = NotificationService.init(quoteDataProvider: dataProvider, notificationCenter: self.notificationCenter)
        for _ in 0 ... 200 {
            self.notificationService.scheduleImperialWisdom()
            self.notificationCenter.fire(notifications: NotificationService.maxNotifications)
        }
        XCTAssert(dataProvider.popRandomQuote().count > 0)
    }
}
