//
//  Cache.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData
import FanapPodAsyncSDK


public class Cache {
    
    var coreDataStack: CoreDataStack = CoreDataStack()
    public let context: NSManagedObjectContext
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init() {
        context = coreDataStack.persistentContainer.viewContext
//        print("context of the cache created")
    }
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func saveContext(subject: String) {
        do {
            try context.save()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            log.verbose("\(subject), has Saved Successfully on CoreData Cache", context: "Cache on ChatSDK")
        } catch let nsError as NSError {
            print("error is:\(nsError.userInfo.debugDescription)")
            log.error("\(subject), Error to save data on CoreData Cache", context: "Cache on ChatSDK")
            fatalError("\(subject), Error to save data on CoreData Cache")
        }
    }
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func deleteAndSave(object: NSManagedObject, withMessage message: String) {
        print("object deleted: \(message)")
        context.delete(object)
        saveContext(subject: message)
    }
    
    
}


