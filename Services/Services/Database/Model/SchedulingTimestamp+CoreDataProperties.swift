//
//  SchedulingTimestamp+CoreDataProperties.swift
//  Services
//
//  Created by Martin on 6/28/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//
//

import Foundation
import CoreData


extension SchedulingTimestamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SchedulingTimestamp> {
        return NSFetchRequest<SchedulingTimestamp>(entityName: "SchedulingTimestamp")
    }

    @NSManaged public var entityID: String?
    @NSManaged public var hour: String?
    @NSManaged public var minute: String?
}
