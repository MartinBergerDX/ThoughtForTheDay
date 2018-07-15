//
//  TriggersDataProvider.swift
//  ThoughtForTheDay
//
//  Created by Martin on 7/15/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import Services

class TriggersDataProvider {
    fileprivate var timestamps: [SchedulingTimestamp] = []
    fileprivate var timestampsToCancel: [SchedulingTimestamp] = []
    
    func load() {
        self.timestamps = SchedulingTimestampDao().findAll()
    }
    
    func cancelled() -> Bool {
        return self.timestampsToCancel.count > 0
    }
    
    func cancel() {
        let dao: SchedulingTimestampDao = SchedulingTimestampDao()
        let _ = dao.deleteEntities(self.timestampsToCancel, save: true)
        self.timestampsToCancel.removeAll()
    }
    
    func appendCancelled(_ timestamp: SchedulingTimestamp) {
        self.timestampsToCancel.append(timestamp)
    }
    
    func setToCancel(_ index: Int) {
        let timestamp: SchedulingTimestamp = self.timestamps.remove(at: index)
        self.appendCancelled(timestamp)
    }
    
    func count() -> Int {
        return self.timestamps.count
    }
    
    func object(at index: Int) -> SchedulingTimestamp {
        return self.timestamps[index]
    }
    
    func updateChanges() {
        if (self.cancelled()) {
            self.cancel()
            ServiceRegistry.shared.notification.reschedule()
        }
    }
}
