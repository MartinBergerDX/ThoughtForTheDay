//
//  UpdateService.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/20/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import UIKit

public protocol UpdateServiceProtocol {
    func setUpdateInterval(_ application: UIApplication)
    func log()
}

class UpdateService: UpdateServiceProtocol {
    static let null: UpdateServiceProtocol = UpdateService.init()
    static let updateInterval: TimeInterval = 3600 * 24
    
    func setUpdateInterval(_ application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(UpdateService.updateInterval)
    }
    
    func log() {
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString: String = dateFormatter.string(from: Date.init())
        print(dateString + " " + "Scheduling notifications in background fetch.", to: &FileLogger.logger)
    }
}
