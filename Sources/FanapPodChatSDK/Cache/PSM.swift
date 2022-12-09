//
// PSM.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.
import CoreData

/// TLDR 'Persistance Service Manager'
class PSM {
    private init() {}
    static let shared = PSM()
    lazy var context: NSManagedObjectContext = persistentContainer.viewContext

    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "CacheDataModel"
        guard let modelURL = Bundle.moduleBundle.url(forResource: modelName, withExtension: "momd") else { fatalError("Couldn't find the mond file!") }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        let container = NSPersistentContainer(name: modelName, managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    internal func save() {
        if context.hasChanges {
            do {
                try context.save()
                Chat.sharedInstance.logger?.log(title: "saved successfully", jsonString: nil)
            } catch {
                let nserror = error as NSError
                #if DEBUG
                    Chat.sharedInstance.logger?.log(title: "error occured in save database", message: "\(nserror), \(nserror.userInfo)")
                #else
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #endif
            }
        } else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "no changes find on context so nothing to save!")
        }
    }
}
