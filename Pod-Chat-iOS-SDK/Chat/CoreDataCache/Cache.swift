//
//  Cache.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData
//import SwiftyBeaver


public class Cache {
    
    var coreDataStack: CoreDataStack = CoreDataStack()
    public let context: NSManagedObjectContext
    
    public init() {
        
        context = coreDataStack.persistentContainer.viewContext
//        print("context of the cache created")
    }
    
    func saveContext(subject: String) {
        do {
            try context.save()
            print("\(subject), has Saved Successfully on CoreData Cache")
        } catch {
            fatalError("\(subject), Error to save data on CoreData Cache")
        }
    }
    
    
    func deleteAndSave(object: NSManagedObject, withMessage message: String) {
        context.delete(object)
        saveContext(subject: message)
    }
    
    
}


