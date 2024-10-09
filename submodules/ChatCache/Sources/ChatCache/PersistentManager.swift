//
// PersistentManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

extension Bundle {
    static var moduleBundle: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(identifier: "org.cocoapods.ChatCache") ?? Bundle.main
#endif
    }
}

/// It leads to loading the MOMD file from the current module, not by default the main module.
final class PMPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        super.defaultDirectoryURL().appendingPathComponent("ChatSDKModel")
    }
}

/// TLDR 'Persistance Service Manager'
public final class PersistentManager: PersistentManagerProtocol {
    public weak var logger: CacheLogDelegate?
    public let baseModelFileName = "ChatSDKModel"
    public var container: NSPersistentContainer?
    public let inMemory: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_TEST"] == "1"

    public init(logger: CacheLogDelegate? = nil) {
        self.logger = logger
    }

    public func viewContext(name: String = "Main") -> NSManagedObjectContextProtocol? {
        guard let context = container?.viewContext else { return nil }
        context.name = name
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    public func newBgTask(name: String = "BGTASK") -> NSManagedObjectContextProtocol? {
        guard let bgTask = container?.newBackgroundContext() else { return nil }
        bgTask.name = name
        bgTask.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bgTask
    }

    /// The structure and model of SQLite database which is a file we created at Resources/ChaSDKModel.xcdataModeld.
    /// Notice: In runtime we should not call this mutliple times and this is the reason why we made this property lazy variable, because we wanted to init this property only once.
    /// If you call this multiple times such as inside a concreate object you will get console warning realted to `mutiple Climas entity`.
    private lazy var modelFile: NSManagedObjectModel = {
        guard let modelURL = Bundle.moduleBundle.url(forResource: baseModelFileName, withExtension: "momd") else { fatalError("Couldn't find the mond file!") }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        return mom
    }()

    public func switchToContainer(userId: Int, completion: @escaping () -> Void) {
        registerTransformers()
        let container = PMPersistentContainer(name: "\(baseModelFileName)-\(userId)", managedObjectModel: modelFile)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { [weak self] desc, error in
            if let error = error {
                self?.logger?.log(message: "error load CoreData persistentstore des:\(desc) error: \(error)", persist: true, error: error)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
        completion()
    }

    public func delete() {
        let storeCordinator = container?.persistentStoreCoordinator
        guard let store = storeCordinator?.persistentStores.first, let url = store.url else { return }
        do {
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                    try storeCordinator?.destroyPersistentStore(at: url, type: .sqlite)
            } else {
                try storeCordinator?.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
            }
            deleteFiles(url: url)
        } catch {
            logger?.log(message: "Error on delete persistent store: \(store) with an error:\n\(error)", persist: true, error: error)
        }
    }

    /// Calling destroyPersistentStore is not enough and it will not delete all core data and SQLite files from the disk it just truncates the database and leaves SQLite files untouched.
    /// We should manually delete files because sometimes the size of SQLite files is too high.
    private func deleteFiles(url: URL) {
        NSFileCoordinator(filePresenter: nil).coordinate(writingItemAt: url.deletingLastPathComponent(), options: .forDeleting, error: nil) { url in
            try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).filter { $0.absoluteString.contains( container?.name ?? "")}.forEach { url in
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}

extension PersistentManager {
    func registerTransformers() {
        RolesValueTransformer.register()
        AssistantValueTransformer.register()
        ReplyInfoValueTransformer.register()
        PinMessageValueTransformer.register()
        ForwardInfoValueTransformer.register()
    }
}
