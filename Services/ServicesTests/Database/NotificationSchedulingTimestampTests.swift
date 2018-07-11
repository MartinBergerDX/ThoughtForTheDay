//
//  NotificationTimeTests.swift
//  NotificationTimeTests
//
//  Created by Martin on 6/22/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import XCTest
@testable import Services

class NotificationSchedulingTimestampTests: XCTestCase {
    var dao: SchedulingTimestampDao = SchedulingTimestampDao.init()
    
    override func setUp() {
        super.setUp()
        self.dao = SchedulingTimestampDao.init()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func scheduleTreeNotificationTimestamps() {
        let nt1: SchedulingTimestamp = self.dao.insertNew()
        nt1.hour = "10"
        nt1.minute = "12"
        let nt2: SchedulingTimestamp = self.dao.insertNew()
        nt2.hour = "11"
        nt2.minute = "02"
        let nt3: SchedulingTimestamp = self.dao.insertNew()
        nt3.hour = "12"
        nt3.minute = "45"
        let _ = self.dao.save()
    }
    
    func testScheduleThreeNotificationTimestamps() {
        self.dao.deleteAll()
        scheduleTreeNotificationTimestamps()
        let times: [SchedulingTimestamp] = self.dao.findAll()
        XCTAssertTrue(times.count == 3)
    }
    
    func testScheduleThreeClearThenScheduleAgain() {
        self.dao.deleteAll()
        scheduleTreeNotificationTimestamps()
        var times: [SchedulingTimestamp] = self.dao.findAll()
        XCTAssertTrue(times.count == 3)
        self.dao.deleteAll()
        times = self.dao.findAll()
        XCTAssertTrue(times.count == 0)
        scheduleTreeNotificationTimestamps()
        times = self.dao.findAll()
        XCTAssertTrue(times.count == 3)
    }
    
    func testSortedAscending() {
        self.dao.deleteAll()
        let nt1: SchedulingTimestamp = self.dao.insertNew()
        nt1.hour = "10"
        nt1.minute = "12"
        let nt2: SchedulingTimestamp = self.dao.insertNew()
        nt2.hour = "06"
        nt2.minute = "02"
        let nt3: SchedulingTimestamp = self.dao.insertNew()
        nt3.hour = "12"
        nt3.minute = "45"
        let nt4: SchedulingTimestamp = self.dao.insertNew()
        nt4.hour = "04"
        nt4.minute = "59"
        let _ = self.dao.save()
        var times: [SchedulingTimestamp] = self.dao.findAllSortedAscending()
        XCTAssertTrue(times[0].hour == "04" && times[0].minute == "59")
        XCTAssertTrue(times[1].hour == "06" && times[1].minute == "02")
        XCTAssertTrue(times[2].hour == "10" && times[2].minute == "12")
        XCTAssertTrue(times[3].hour == "12" && times[3].minute == "45")
    }
    
    func testFindByTime() {
        self.dao.deleteAll()
        let nt1: SchedulingTimestamp = self.dao.insertNew()
        nt1.hour = "10"
        nt1.minute = "12"
        let _ = self.dao.save()
        XCTAssert(self.dao.find(hour: "10", minute: "12") != nil)
    }
}
