//
//  CoreDataProtocol.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

protocol IdProtocol {}
extension Int: IdProtocol {}
extension String: IdProtocol {}

protocol CoreDataProtocol {
    associatedtype Entity: NSManagedObject
    associatedtype Model: Codable
    associatedtype Id: IdProtocol
    init(context: NSManagedObjectContext, logger: Logger)
    var context: NSManagedObjectContext { get set }
    var logger: Logger { get }
    var idName: String { get }
    func idPredicate(id: Id) -> NSPredicate
    func save()
    func first(with id: Id, _ completion: @escaping (Entity?) -> Void)
    func find(predicate: NSPredicate, _ completion: @escaping ([Entity]) -> Void)
    func insert(model: Model)
    func insert(models: [Model])
    func delete(entity: Entity)
    func update(model: Model, entity: Entity)
    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate)
    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID])
    func insertObjects(_ bgTask: NSManagedObjectContext, _ makeEntities: @escaping ((NSManagedObjectContext) throws -> Void))
    func batchUpdate(_ bgTask: NSManagedObjectContext, _ updateObjects: @escaping (NSManagedObjectContext) -> Void)
    func batchDelete(_ bgTask: NSManagedObjectContext, entityName: String, idName: String, _ ids: [Int])
    func batchDelete(_ bgTask: NSManagedObjectContext, entityName: String, predicate: NSPredicate)
    func fetchWithOffset(entityName: String, count: Int?, offset: Int?, predicate: NSPredicate?, sortDescriptor: [NSSortDescriptor]?, _ completion: @escaping ([Entity], Int) -> Void)
}

extension CoreDataProtocol {
    func save() {
        if context.hasChanges == true {
            do {
                try context.save()
                context.reset()
                logger.log(title: "saved successfully", persist: false, type: .internalLog)
            } catch {
                let nserror = error as NSError
                logger.log(message: "error occured in save CoreData: \(nserror), \(nserror.userInfo)", persist: true, level: .error, type: .internalLog)
            }
        } else {
            logger.log(title: "CHAT_SDK:", message: "no changes find on context so nothing to save!", persist: false, type: .internalLog)
        }
    }

    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [context]
        )
    }

    func insertObjects(_ bgTask: NSManagedObjectContext, _ makeEntities: @escaping ((NSManagedObjectContext) throws -> Void)) {
        bgTask.perform {
            try makeEntities(bgTask)
            save()
            let insertedObjectIds = bgTask.insertedObjects.map(\.objectID)
            let updatedObjectIds = bgTask.updatedObjects.map(\.objectID)
            mergeChanges(key: NSInsertedObjectsKey, insertedObjectIds)
            // For entities with constraint we the constraint will update not insert, because we use trump policy in bgTask Context.
            mergeChanges(key: NSUpdatedObjectsKey, updatedObjectIds)
        }
    }

    func batchUpdate(_ bgTask: NSManagedObjectContext, _ updateObjects: @escaping (NSManagedObjectContext) -> Void) {
        bgTask.perform {
            updateObjects(bgTask)
            save()
            let updatedObjectIds = bgTask.updatedObjects.map(\.objectID)
            mergeChanges(key: NSUpdatedObjectsKey, updatedObjectIds)
        }
    }

    func batchDelete(_ bgTask: NSManagedObjectContext, entityName: String, idName: String = "id", _ ids: [Int]) {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        req.predicate = NSPredicate(format: "\(idName) IN %@", ids.map { $0 as NSNumber })
        let request = NSBatchDeleteRequest(fetchRequest: req)
        request.resultType = .resultTypeObjectIDs
        bgTask.perform {
            let deleteResult = try bgTask.execute(request) as? NSBatchDeleteResult
            save()
            mergeChanges(key: NSDeletedObjectsKey, deleteResult?.result as? [NSManagedObjectID] ?? [])
        }
    }

    func batchDelete(_ bgTask: NSManagedObjectContext, entityName: String, predicate: NSPredicate) {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        req.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: req)
        request.resultType = .resultTypeObjectIDs
        bgTask.perform {
            let deleteResult = try bgTask.execute(request) as? NSBatchDeleteResult
            save()
            mergeChanges(key: NSDeletedObjectsKey, deleteResult?.result as? [NSManagedObjectID] ?? [])
        }
    }

    public func fetchWithOffset(entityName: String, count: Int?, offset: Int?, predicate: NSPredicate? = nil, sortDescriptor: [NSSortDescriptor]? = nil, _ completion: @escaping ([Entity], Int) -> Void) {
        context.perform {
            let req = NSFetchRequest<Entity>(entityName: entityName)
            if let sortDescriptors = sortDescriptor {
                req.sortDescriptors = sortDescriptors
            }
            req.predicate = predicate
            let totalCount = (try? self.context.count(for: req)) ?? 0
            req.fetchLimit = count ?? 50
            req.fetchOffset = offset ?? 0
            let objects = try self.context.fetch(req)
            completion(objects, totalCount)
        }
    }
}
