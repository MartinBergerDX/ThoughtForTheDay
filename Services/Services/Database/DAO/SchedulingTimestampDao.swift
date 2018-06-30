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
        var sd: [NSSortDescriptor] = []
        if let dob: NSSortDescriptor = self.defaultOrderBy {
            sd.append(dob)
        }
        sd.append(NSSortDescriptor(key: "minute", ascending: true))
        return self.fetchWithPredicate(nil, sortDescriptors: sd)
    }
}
