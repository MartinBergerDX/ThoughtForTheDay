//
//  DateUtils.swift
//  ThoughtForTheDay
//
//  Created by Martin on 7/11/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation

class DateUtils {
    static let shared: DateUtils = DateUtils.init()
    var dateFormatter: DateFormatter = DateFormatter.init()
    init() {
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .none
    }
}
