//
//  CoreDataStack.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData

//public class CoreDataStack {
//    private init() {}
//    static let shared = CoreDataStack()

public class CoreDataStack: NSObject {
    
    // MARK: - Core Data stack
    
//    public static let sharedInstance = CoreDataStack()
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "CacheDataModel")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error {
//                fatalError("Unresolved error \(error), \(error)")
//            }
//        })
//        return container
//    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let momdName = "CacheDataModel" //pass this as a parameter
        guard let bundle = Bundle(identifier: "com.fanapSoft.FanapPodChatSDK") else { fatalError("Error loading bundle") }
        print("bundle = \(bundle)")
        guard let modelPath = bundle.path(forResource: momdName, ofType: ".momd") else { fatalError("Error loading model from bundle") }
        print("modelPath = \(modelPath)")
        let modelURL = URL(fileURLWithPath: modelPath)
        print("modelURL = \(modelURL)")
//        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension: "momd") else { fatalError("Error loading model from bundle") }
        /*
         The managed object model for the application.
         It is a fatal error for the application not to be able to find and load its model.
         */
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        
//         let momdName = "CacheDataModel" //pass this as a parameter
//         guard let modelURL = Bundle(for: type(of: self)).url(forResource: "NewChat/\(momdName)", withExtension: "momd") else { fatalError("Error loading model from bundle") }
//         guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
//         let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        
        /*
         guard let bundleURL = Bundle(for: type(of: self)).url(forResource: "NewChat", withExtension: "bundle") else { fatalError("0") }
         
         //        guard let bundleURL = Bundle(forClass: self).URLForResource("myFramework", withExtension: "bundle") else { fatalError("1") }
         guard let frameworkBundle = Bundle(url: bundleURL) else { fatalError("2") }
         guard let momURL = frameworkBundle.url(forResource: "CacheDataModel", withExtension: "momd") else { fatalError("3") }
         */
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


