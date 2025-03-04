//
// BaseCoreDataManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import CoreData

public class BaseCoreDataManager<T: EntityProtocol>: CoreDataProtocol, @unchecked Sendable {
    public typealias Entity = T
    public var container: PersistentManagerProtocol
    public let logger: CacheLogDelegate
    @MainActor
    public var viewContext: CacheManagedContext { container.viewContext(name: "Main")! }
    public var bgContext: CacheManagedContext { container.newBgTask(name: "BGTask")! }

    required public init(container: PersistentManagerProtocol, logger: CacheLogDelegate) {
        self.container = container
        self.logger = logger
    }

    public func insert(model: Entity.Model, context: CacheManagedContext) {
        let entity = Entity.insertEntity(context)
        entity.update(model)
    }

    public func insert(models: [Entity.Model]) {
        insertObjects() { context in
            models.forEach { model in
                self.insert(model: model, context: context)
            }
        }
    }

    public func idPredicate(id: Entity.Id) -> NSPredicate {
        NSPredicate(format: "\(Entity.idName) == \(Entity.queryIdSpecifier)", id as! CVarArg)
    }

    @MainActor
    public func first(with id: Entity.Id) -> Entity? {
        let req = Entity.fetchRequest()
        req.predicate = self.idPredicate(id: id)
        req.fetchLimit = 1
        return try? viewContext.fetch(req).first
    }
    
    @MainActor
    public func find(predicate: SendableNSPredicate) -> [Entity]? {
        let req = Entity.fetchRequest()
        req.predicate = predicate.predicate
        return try? self.viewContext.fetch(req)
    }

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        let context = bgContext
        context.perform {
            let batchRequest = NSBatchUpdateRequest(entityName: Entity.name)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            let updateResult = try? context.execute(batchRequest) as? NSBatchUpdateResult
            if let updatedObjectIds = updateResult?.result as? [NSManagedObjectID], updatedObjectIds.count > 0 {
                Task { @MainActor [weak self] in
                    self?.mergeChanges(key: NSUpdatedObjectIDsKey, updatedObjectIds)
                }
            }
        }
    }

    public func save(context: CacheManagedContext) {
        if context.hasChanges == true {
            do {
                try context.save()
                context.reset()
                logger.log(message: "saved successfully", persist: false, error: nil)
            } catch {
                let nserror = error as NSError
                logger.log(message: "Error occured in save CoreData: \(nserror)", persist: true, error: nserror)
            }
        } else {
            logger.log(message: "no changes find on context so nothing to save!", persist: false, error: nil)
        }
    }

    @MainActor
    public func saveViewContext() {
        save(context: viewContext)
    }
    
    @MainActor
    public func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [viewContext.context as! NSManagedObjectContext]
        )
    }

    public func insertObjects(_ makeEntities: @escaping @Sendable (CacheManagedContext) throws -> Void) {
        let context = bgContext
        context.perform { [weak self] in
            try makeEntities(context)
            self?.save(context: context)
        }
    }

    public func delete(_ id: Int) {
        batchDelete([id])
    }

    public func batchDelete(_ ids: [Int]) {
        let predicate = NSPredicate(format: "\(Entity.idName) IN %@", ids.map { $0 as NSNumber })
        batchDelete(predicate: predicate)
    }

    public func batchDelete(predicate: NSPredicate) {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.name)
        req.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: req)
        request.resultType = .resultTypeObjectIDs
        let context = bgContext
        context.perform {
            let deleteResult = try context.execute(request) as? NSBatchDeleteResult
            if let deletedObjectIds = deleteResult?.result as? [NSManagedObjectID], deletedObjectIds.count > 0 {
                Task { @MainActor [weak self] in
                    self?.mergeChanges(key: NSDeletedObjectIDsKey, deletedObjectIds)
                }
            }
        }
    }

    @MainActor
    public func fetchWithOffset(count: Int = 25, offset: Int = 0, predicate: SendableNSPredicate? = nil, sortDescriptor: [SendableNSSortDescriptor]? = nil) -> ([Entity]?, Int)? {
        let req = NSFetchRequest<Entity>(entityName: Entity.name)
        req.sortDescriptors = sortDescriptor?.compactMap {$0.sort}
        req.predicate = predicate?.predicate
        let totalCount = (try? self.viewContext.count(for: req)) ?? 0
        req.fetchLimit = count
        req.fetchOffset = offset
        let objects = try? self.viewContext.fetch(req)
        return (objects, totalCount)
    }

    @MainActor
    public func all() -> [Entity] {
        let req = Entity.fetchRequest()
        let entities = try? self.viewContext.fetch(req)
        return entities ?? []
    }

    public func findOrCreate(_ id: Entity.Id, _ context: CacheManagedContext) -> Entity {
        let req = T.fetchRequest()
        req.predicate = self.idPredicate(id: id)
        req.fetchLimit = 1
        let entity = try? context.context.fetch(req).first
        return entity ?? T.insertEntity(context)
    }

    public func truncate() {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.name)
        let batchReq = NSBatchDeleteRequest(fetchRequest: req)
        batchReq.resultType = .resultTypeObjectIDs
        let context = bgContext
        context.perform {
            let deleteResult = try context.execute(batchReq) as? NSBatchDeleteResult
            if let deletedObjectIds = deleteResult?.result as? [NSManagedObjectID], deletedObjectIds.count > 0 {
                Task { @MainActor [weak self] in
                    self?.mergeChanges(key: NSDeletedObjectIDsKey, deletedObjectIds)
                }
            }
        }
    }

    @MainActor
    public func get(id: Entity.Id) -> Entity? {
        let req = Entity.fetchRequest()
        req.predicate = idPredicate(id: id)
        req.fetchLimit = 1
        return try? viewContext.fetch(req).first
    }
}
