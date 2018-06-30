//
//  GenericDao.swift
//  ThoughtForTheDay
//
//  Created by Martin on 6/14/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import CoreData

public class GenericDao<T:NSManagedObject> {

    var moc: NSManagedObjectContext
    var entityName: String = ""
    var defaultOrderBy: NSSortDescriptor?
    var attributeID: String = "entityID"

    lazy var entityDescription: NSEntityDescription = {
        var ed = NSEntityDescription.entity(forEntityName: self.entityName, in: self.moc)
        return ed!
    }()

    public init() {
        if let _ : String = ProcessInfo.processInfo.environment["TESTING"] {
            self.moc = CoreDataStack.init(modelName: CoreDataStack.defaultModelName).managedObjectContext
        } else {
            self.moc = ServiceRegistry.shared.database.managedObjectContext
        }
        self.entityName = NSStringFromClass(T.self).components(separatedBy: ".").last!
    }

    public func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fr.entity = self.entityDescription
        if let dob = self.defaultOrderBy {
            fr.sortDescriptors = [dob]
        }
        return fr
    }

    public func fetchWithPredicate(_ predicate: NSPredicate?, sortDescriptors: Array<NSSortDescriptor>?) -> Array<T> {
        return self.fetchWithPredicate(predicate, sortDescriptors: sortDescriptors, properties: nil)
    }

    public func fetchWithPredicate(_ predicate: NSPredicate?, sortDescriptors: Array<NSSortDescriptor>?, properties: Array<String>?) -> Array<T> {
        let fetchRequest = self.fetchRequest();
        fetchRequest.predicate = predicate

        var error: NSError?
        var items: [AnyObject]?
        do {
            items = try self.moc.fetch(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            items = nil
        }
        if error != nil {
            print("Error fetching data: \(String(describing: error?.localizedDescription))")
            items = []
        }

        if let ret = items as? [T] {
            return ret;
        }

        return []
    }

    public func isTableEmpty() -> Bool {
        let count = try? self.moc.count(for: self.fetchRequest())
        if count == NSNotFound {
            print("isTableEmpty error")
            return true
        }
        return count == 0
    }

    public func totalRowsCount() -> Int {
        return try! self.moc.count(for: self.fetchRequest())
    }

    public func insertNew() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: self.moc) as! T
    }

    public func findByID(_ entityID: AnyObject) -> T? {
        var predicate: NSPredicate?

        if let strID = entityID as? String {
            predicate = NSPredicate(format: "%K = %@", self.attributeID, strID)
        } else if let numID = entityID as? NSNumber {
            predicate = NSPredicate(format: "%K = %d", self.attributeID, numID.intValue)
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongEntityID"), reason: "entityID is not proper type", userInfo: nil).raise()
            return nil
        }

        let result = self.fetchWithPredicate(predicate, sortDescriptors: nil)
        return result.first as T?
    }

    public func getExistingOrNew(_ entityID: AnyObject) -> T {
        var entity: T? = self.findByID(entityID)
        if entity == nil {
            entity = self.insertNew()
            if let object: NSManagedObject = entity {
                object.setValue(entityID, forKey: self.attributeID)
            }
        }
        return entity!
    }

    public func findAll() -> Array<T> {
        if let dob = self.defaultOrderBy {
            return self.fetchWithPredicate(nil, sortDescriptors: [dob])
        } else {
            return self.fetchWithPredicate(nil, sortDescriptors: nil)
        }
    }

    public func findAllByIDs(_ entityIDs: Array<AnyObject>, sortDescriptors: Array<NSSortDescriptor>?) -> Array<T> {
        if entityIDs.count == 0 {
            return []
        }

        let predicate = NSPredicate(format: "(%K IN %@)", self.attributeID, entityIDs)
        let results = self.fetchWithPredicate(predicate, sortDescriptors: sortDescriptors)
        return results
    }

    public func save() -> Bool {
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("Error saving \(self.entityName): \(error)")
            return false
        }
        return true
    }

    public func saveToPersistentStore() -> Bool {
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("Error saving to persistent store: \(error)")
            return false
        }
        return true
    }

    public func delete(_ entity: T, save: Bool) -> Bool {
        self.moc.delete(entity)
        if (save) {
            return self.saveToPersistentStore()
        } else {
            return true
        }
    }

    public func deleteEntities(_ entities: Array<T>, save: Bool) -> Bool {
        for entity in entities {
            self.moc.delete(entity)
        }

        if save {
            return self.saveToPersistentStore()
        }
        return true
    }

    public func domainToCoreData(_ domain: AnyObject, dbObject: T) {
        // abstract
    }

    public func coreDataToDomain(_ dbObject: T, domain: AnyObject) {
        // abstract
    }
    
    public func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: self.entityName)
        let deleteRequest: NSBatchDeleteRequest = NSBatchDeleteRequest.init(fetchRequest: fetchRequest)
        do {
            try self.moc.persistentStoreCoordinator?.execute(deleteRequest, with: self.moc)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
