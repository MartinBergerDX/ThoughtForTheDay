//
//  QuoteEvent+CoreDataProperties.swift
//  
//
//  Created by Martin on 7/15/18.
//
//

import Foundation
import CoreData


extension QuoteEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteEvent> {
        return NSFetchRequest<QuoteEvent>(entityName: "QuoteEvent")
    }

    @NSManaged public var entityID: String?
    @NSManaged public var hour: String?
    @NSManaged public var minute: String?

}
