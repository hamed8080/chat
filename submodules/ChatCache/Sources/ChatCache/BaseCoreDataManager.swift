//
// BaseCoreDataManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import CoreData

public class BaseCoreDataManager<T: EntityProtocol>: CoreDataProtocol {
    public typealias Entity = T
    public var container: PersistentManagerProtocol
    public let logger: CacheLogDelegate
    public var viewContext: NSManagedObjectContextProtocol { container.viewContext(name: "Main")! }
    public var bgContext: NSManagedObjectContextProtocol { container.newBgTask(name: "BGTask")! }
    private let mainQueue = DispatchQueue.main

    required public init(container: PersistentManagerProtocol, logger: CacheLogDelegate) {
        self.container = container
        self.logger = logger
    }

    public func insert(model: Entity.Model, context: NSManagedObjectContextProtocol) {
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

    public func first(with id: Entity.Id, context: NSManagedObjectContextProtocol, completion: @escaping (Entity?) -> Void) {
        let req = Entity.fetchRequest()
        req.predicate = self.idPredicate(id: id)
        req.fetchLimit = 1
        let entity = try? context.fetch(req).first
        completion(entity)
    }

    public func firstOnMain(with id: Entity.Id, context: NSManagedObjectContextProtocol, completion: @escaping (Entity?) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            let req = Entity.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            req.fetchLimit = 1
            let entity = try? context.fetch(req).first
            completion(entity)
        }
    }

    public func find(predicate: NSPredicate, completion: @escaping ([Entity]) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            viewContext.perform {
                let req = Entity.fetchRequest()
                req.predicate = predicate
                let entities = try self.viewContext.fetch(req)
                completion(entities)
            }
        }
    }

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        let context = bgContext
        context.perform { [weak self] in
            let batchRequest = NSBatchUpdateRequest(entityName: Entity.name)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            let updateResult = try? context.execute(batchRequest) as? NSBatchUpdateResult
            if let updatedObjectIds = updateResult?.result as? [NSManagedObjectID], updatedObjectIds.count > 0 {
                self?.mergeChanges(key: NSUpdatedObjectIDsKey, updatedObjectIds)
            }
        }
    }

    public func save(context: NSManagedObjectContextProtocol) {
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

    public func saveViewContext() {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            save(context: viewContext)
        }
    }

    public func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [viewContext as! NSManagedObjectContext]
        )
    }

    public func insertObjects(_ makeEntities: @escaping ((NSManagedObjectContextProtocol) throws -> Void)) {
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
        context.perform { [weak self] in
            let deleteResult = try context.execute(request) as? NSBatchDeleteResult
            if let deletedObjectIds = deleteResult?.result as? [NSManagedObjectID], deletedObjectIds.count > 0 {
                self?.mergeChanges(key: NSDeletedObjectIDsKey, deletedObjectIds)
            }
        }
    }

    public func fetchWithOffset(count: Int = 25, offset: Int = 0, predicate: NSPredicate? = nil, sortDescriptor: [NSSortDescriptor]? = nil, _ completion: @escaping ([Entity], Int) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            viewContext.perform {
                let req = NSFetchRequest<Entity>(entityName: Entity.name)
                req.sortDescriptors = sortDescriptor
                req.predicate = predicate
                let totalCount = (try? self.viewContext.count(for: req)) ?? 0
                req.fetchLimit = count
                req.fetchOffset = offset
                let objects = try self.viewContext.fetch(req)
                completion(objects, totalCount)
            }
        }
    }

    public func all(_ completion: @escaping ([Entity]) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            viewContext.perform {
                let req = Entity.fetchRequest()
                let entities = try self.viewContext.fetch(req)
                completion(entities)
            }
        }
    }

    public func fetchWithObjectIds(ids: [NSManagedObjectID], _ completion: @escaping ([Entity]) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            viewContext.perform {
                let req = Entity.fetchRequest()
                let predicate = NSPredicate(format: "self IN %@", ids)
                req.predicate = predicate
                let entities = try self.viewContext.fetch(req)
                completion(entities)
            }
        }
    }

    public func findOrCreate(_ id: Entity.Id, _ context: NSManagedObjectContextProtocol) -> Entity {
        let req = T.fetchRequest()
        req.predicate = self.idPredicate(id: id)
        req.fetchLimit = 1
        let entity = try? context.fetch(req).first
        return entity ?? T.insertEntity(context)
    }

    public func truncate() {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.name)
        let batchReq = NSBatchDeleteRequest(fetchRequest: req)
        batchReq.resultType = .resultTypeObjectIDs

        let context = bgContext
        context.perform { [weak self] in
            let deleteResult = try context.execute(batchReq) as? NSBatchDeleteResult
            if let deletedObjectIds = deleteResult?.result as? [NSManagedObjectID], deletedObjectIds.count > 0 {
                self?.mergeChanges(key: NSDeletedObjectIDsKey, deletedObjectIds)
            }
        }
    }

    public func get(id: Entity.Id) -> Entity? {
        let req = Entity.fetchRequest()
        req.predicate = idPredicate(id: id)
        req.fetchLimit = 1
        return try? viewContext.fetch(req).first
    }
}
