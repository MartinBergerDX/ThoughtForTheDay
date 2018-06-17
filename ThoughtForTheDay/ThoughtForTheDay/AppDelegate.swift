//
//  AppDelegate.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        let dateFormatter: DateFormatter = DateFormatter.init()
//        dateFormatter.dateStyle = .short
//        let today: Date = Date.init()
//        var components: DateComponents = DateComponents.init()
//        components.hour = 14
//        components.minute = 0
//        Calendar.autoupdatingCurrent.enumerateDates(startingAfter: today, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime) { (date: Date?, um: Bool, yeah: inout Bool) in
//            if let theDate: Date = date {
//                print(dateFormatter.string(from: theDate))
//            }
//        }

//        let dateFormatter: DateFormatter = DateFormatter.init()
//        dateFormatter.dateStyle = .short
//        let today: Date = Date.init()
//        print(dateFormatter.string(from: today))
//        var components: DateComponents = DateComponents.init()
//        components.hour = 14
//        components.minute = 0
//        let nextDate = Calendar.autoupdatingCurrent.nextDate(after: today, matching: components, matchingPolicy: Calendar.MatchingPolicy.nextTime) ?? today
//        print(dateFormatter.string(from: nextDate))
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ServiceRegistry.shared.notification.scheduleImperialWisdom()
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

