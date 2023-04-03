//
// PersistentManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Logger

/// It leads to loading the MOMD file from the current module, not by default the main module.
final class PMPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        super.defaultDirectoryURL().appendingPathComponent("ChatSDKModel")
    }
}

/// TLDR 'Persistance Service Manager'
public final class PersistentManager {
    var logger: Logger?
    var cacheEnabled: Bool
    let baseModelFileName = "ChatSDKModel"

    init(logger: Logger? = nil, cacheEnabled: Bool = false) {
        self.logger = logger
        self.cacheEnabled = cacheEnabled
    }

    var context: NSManagedObjectContext? {
        guard let context = container?.viewContext else { return nil }
        context.name = "Main"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func newBgTask() -> NSManagedObjectContext? {
        guard let bgTask = container?.newBackgroundContext() else { return nil }
        bgTask.name = "BGTASK"
        bgTask.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bgTask
    }

    /// The structure and model of SQLite database which is a file we created at Resources/ChaSDKModel.xcdataModeld.
    /// Notice: In runtime we should not call this mutliple time and this is the reason why we made this property lazy variable, because we wanted to init this property only once.
    /// If you call this multiple time such as inside a concreate object you will get console warning realted to `mutiple Climas entity`.
    lazy var modelFile: NSManagedObjectModel = {
        guard let modelURL = Bundle.moduleBundle.url(forResource: baseModelFileName, withExtension: "momd") else { fatalError("Couldn't find the mond file!") }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        return mom
    }()

    var container: NSPersistentContainer?

    func switchToContainer(userId: Int) {
        RolesValueTransformer.register()
        AssistantValueTransformer.register()
        let container = PMPersistentContainer(name: "\(baseModelFileName)-\(userId)", managedObjectModel: modelFile)
        container.loadPersistentStores { [weak self] desc, error in
            if let error = error {
                self?.logger?.log(message: "error load CoreData persistentstore des:\(desc) error: \(error)", persist: true, level: .error, type: .internalLog)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }

    func delete() {
        let storeCordinator = container?.persistentStoreCoordinator
        guard let store = storeCordinator?.persistentStores.first, let url = store.url else { return }
        do {
            if #available(iOS 15.0, *) {
                try storeCordinator?.destroyPersistentStore(at: url, type: .sqlite)
            } else {
                try storeCordinator?.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
            }
        } catch {
            print("Error to delete the database file: \(error.localizedDescription)")
        }
    }
}
