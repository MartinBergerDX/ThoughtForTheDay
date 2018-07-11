//
//  SchedulingTimestampDao.swift
//  Services
//
//  Created by Martin on 6/28/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation

public class SchedulingTimestampDao : GenericDao<SchedulingTimestamp> {
    override public init() {
        super.init()
        defaultOrderBy = NSSortDescriptor(key: "hour", ascending: true)
    }
    
    func findAllSortedAscending() -> Array<SchedulingTimestamp> {
        return self.fetchWithPredicate(nil, sortDescriptors: sortDescriptors())
    }
    
    func find(hour: String, minute: String) -> SchedulingTimestamp? {
        let predicate: NSPredicate = NSPredicate.init(format: "(hour LIKE[cd] %@) AND (minute LIKE[cd] %@)", hour, minute)
        return fetchWithPredicate(predicate, sortDescriptors: sortDescriptors()).first
    }
    
    public func scheduledTimestampExists(with hour: String, minute: String) -> Bool {
        return find(hour: hour, minute: minute) != nil
    }
    
    fileprivate func sortDescriptors() -> [NSSortDescriptor] {
        var sd: [NSSortDescriptor] = []
        if let dob: NSSortDescriptor = self.defaultOrderBy {
            sd.append(dob)
        }
        sd.append(NSSortDescriptor(key: "minute", ascending: true))
        return sd
    }
}
