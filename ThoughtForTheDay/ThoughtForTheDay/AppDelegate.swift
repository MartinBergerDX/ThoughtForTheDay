//
//  AppDelegate.swift
//  ThoughtForTheDay
//
//  Created by Martin on 5/26/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import UIKit
import Services

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServiceRegistry.shared.notification.register()
        ServiceRegistry.shared.update.setUpdateInterval(application)
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
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        ServiceRegistry.shared.notification.scheduleImperialWisdom()
        ServiceRegistry.shared.update.log()
        completionHandler(.noData)
    }
}

