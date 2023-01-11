//
// PersistentManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

/// It leads to loading the MOMD file from the current module, not by default the main module.
class PMPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        super.defaultDirectoryURL().appendingPathComponent("ChatSDKModel")
    }
}

/// TLDR 'Persistance Service Manager'
public class PersistentManager {
    var logger: Logger?
    var cacheEnabled: Bool

    init(logger: Logger? = nil, cacheEnabled: Bool = false) {
        self.logger = logger
        self.cacheEnabled = cacheEnabled
    }

    lazy var context: NSManagedObjectContext = container.viewContext

    func newBgTask() -> NSManagedObjectContext {
        let bgTask = container.newBackgroundContext()
        bgTask.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        bgTask.name = "BGTASK"
        return bgTask
    }

    lazy var container: NSPersistentContainer = {
        RolesValueTransformer.register()
        AssistantValueTransformer.register()
        let modelName = "ChatSDKModel"
        guard let modelURL = Bundle.moduleBundle.url(forResource: modelName, withExtension: "momd") else { fatalError("Couldn't find the mond file!") }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        let container = PMPersistentContainer(name: modelName, managedObjectModel: mom)
        container.loadPersistentStores { desc, error in
            if let error = error {
                self.logger?.log(message: "error load CoreData persistentstore des:\(desc) error: \(error)", level: .error)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    func save(context: NSManagedObjectContext, _ logger: Logger? = nil) {
        if context.hasChanges == true, cacheEnabled == true {
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
