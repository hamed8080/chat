//
// PersistentManager.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

/// TLDR 'Persistance Service Manager'
public final class PersistentManager {
    let baseModelFileName = "Logger"
    var container: NSPersistentContainer?

    init() {
        do {
            try loadContainer()
        } catch {
            print(error)
        }
    }

    var context: NSManagedObjectContext? {
        guard let context = container?.viewContext else { return nil }
        context.name = "Main"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    var newBgTask: NSManagedObjectContext? {
        guard let bgTask = container?.newBackgroundContext() else { return nil }
        bgTask.name = "BGTASK"
        bgTask.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bgTask
    }

    func modelFile() throws -> NSManagedObjectModel {
        guard let modelURL = Bundle.moduleBundle.url(forResource: baseModelFileName, withExtension: "momd") else { throw LoggerError.momdFile }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { throw LoggerError.modelFile }
        return mom
    }

    func loadContainer() throws {
        let container = NSPersistentContainer(name: "\(baseModelFileName)", managedObjectModel: try modelFile())
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("error load CoreData persistentstore des:\(desc) error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }

    func delete() throws {
        let storeCordinator = container?.persistentStoreCoordinator
        guard let store = storeCordinator?.persistentStores.first, let url = store.url else { throw LoggerError.persistentStore }
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            try storeCordinator?.destroyPersistentStore(at: url, type: .sqlite)
        } else {
            try storeCordinator?.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
        }
    }
}
