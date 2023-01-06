//
// PersistentManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

/// It leads to loading the MOMD file from the current module, not by default the main module.
class PMPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        defaultDirectoryURL().appendingPathComponent("ChatSDKModel")
    }
}

/// TLDR 'Persistance Service Manager'
class PersistentManager {
    var logger: Logger?

    init(logger: Logger? = nil) {
        self.logger = logger
    }

    lazy var context: NSManagedObjectContext = container.viewContext

    lazy var container: NSPersistentContainer = {
        let container = PMPersistentContainer(name: "CacheDataModel")
        RolesValueTransformer.register()
        AssistantValueTransformer.register()
        container.loadPersistentStores { desc, error in
            if let error = error {
                self.logger?.log(message: "error load CoreData persistentstore des:\(desc) error: \(error)", level: .error)
            }
        }
        return container
    }()

    internal func save(_ logger: Logger? = nil) {
        if context.hasChanges {
            do {
                try context.save()
                logger?.log(title: "saved successfully", jsonString: nil)
            } catch {
                let nserror = error as NSError
                logger?.log(message: "error occured in save CoreData: \(nserror), \(nserror.userInfo)", level: .error)
            }
        } else {
            logger?.log(title: "CHAT_SDK:", message: "no changes find on context so nothing to save!")
        }
    }
}
