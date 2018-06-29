//
//  CoreDataStack.swift
//  Services
//
//  Created by Martin on 6/27/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import CoreData

public protocol DatabaseProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
}

public final class CoreDataStack : DatabaseProtocol {
    static let null: DatabaseProtocol = CoreDataStack.init(modelName: "null")
    static let defaultModelName: String = "DatabaseModel"
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    public private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelUrl: URL = Bundle(for: type(of: self)).url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to find data model")
        }
        guard let managedObjectModel: NSManagedObjectModel = NSManagedObjectModel.init(contentsOf: modelUrl) else {
            fatalError("Unable to load data model")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        return persistentStoreCoordinator
    }()
}
