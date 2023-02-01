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
    init(context: NSManagedObjectContext?, pm: PersistentManager, logger: Logger?)
    var pm: PersistentManager { get }
    var context: NSManagedObjectContext? { get set }
    var logger: Logger? { get }
    var idName: String { get }
    var entityName: String { get }
    func idPredicate(id: Id) -> NSPredicate
    func save()
    func first(with id: Id) -> Entity?
    func find(predicate: NSPredicate) -> [Entity]
    func insert(context: NSManagedObjectContext, model: Model)
    func insert(models: [Model])
    func delete(entity: Entity)
    func update(model: Model, entity: Entity)
    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate)
    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID])
    func insertObjects(_ makeEntities: @escaping ((NSManagedObjectContext) -> Void))
    func batchUpdate(_ updateObjects: @escaping (NSManagedObjectContext) -> Void)
    func batchDelete(entityName: String, idName: String, _ ids: [Int])
    func batchDelete(entityName: String, predicate: NSPredicate)
}

extension CoreDataProtocol {
    func save() {
        if context?.hasChanges == true {
            do {
                try context?.save()
                logger?.log(title: "saved successfully", jsonString: nil)
            } catch {
                let nserror = error as NSError
                logger?.log(message: "error occured in save CoreData: \(nserror), \(nserror.userInfo)", level: .error)
            }
        } else {
            logger?.log(title: "CHAT_SDK:", message: "no changes find on context so nothing to save!")
        }
    }

    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        guard let context = context else { return }
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [context]
        )
    }

    func insertObjects(_ makeEntities: @escaping ((NSManagedObjectContext) -> Void)) {
        guard let bgTask = pm.newBgTask() else { return }
        bgTask.perform {
            makeEntities(bgTask)
            try? bgTask.save()
            let insertedObjectIds = bgTask.insertedObjects.map(\.objectID)
            let updatedObjectIds = bgTask.updatedObjects.map(\.objectID)
            mergeChanges(key: NSInsertedObjectsKey, insertedObjectIds)
            // For entities with constraint we the constraint will update not insert, because we use trump policy in bgTask Context.
            mergeChanges(key: NSUpdatedObjectsKey, updatedObjectIds)
        }
    }

    func batchUpdate(_ updateObjects: @escaping (NSManagedObjectContext) -> Void) {
        guard let bgTask = pm.newBgTask() else { return }
        bgTask.perform {
            updateObjects(bgTask)
            try? bgTask.save()
            let updatedObjectIds = bgTask.updatedObjects.map(\.objectID)
            mergeChanges(key: NSUpdatedObjectsKey, updatedObjectIds)
        }
    }

    func batchDelete(entityName: String, idName: String = "id", _ ids: [Int]) {
        guard let bgTask = pm.newBgTask() else { return }
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        req.predicate = NSPredicate(format: "\(idName) IN %@", ids.map { $0 as NSNumber })
        let request = NSBatchDeleteRequest(fetchRequest: req)
        request.resultType = .resultTypeObjectIDs
        bgTask.perform {
            let deleteResult = try? bgTask.execute(request) as? NSBatchDeleteResult
            try? bgTask.save()
            mergeChanges(key: NSDeletedObjectsKey, deleteResult?.result as? [NSManagedObjectID] ?? [])
        }
    }

    func batchDelete(entityName: String, predicate: NSPredicate) {
        guard let bgTask = pm.newBgTask() else { return }
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        req.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: req)
        request.resultType = .resultTypeObjectIDs
        bgTask.perform {
            let deleteResult = try? bgTask.execute(request) as? NSBatchDeleteResult
            try? bgTask.save()
            mergeChanges(key: NSDeletedObjectsKey, deleteResult?.result as? [NSManagedObjectID] ?? [])
        }
    }

    public func fetchWithOffset<T: NSManagedObject>(count: Int?,
                                                    offset: Int?,
                                                    predicate: NSPredicate? = nil,
                                                    sortDescriptor: [NSSortDescriptor]? = nil) -> (objects: [T], totalCount: Int)
    {
        let req = NSFetchRequest<T>(entityName: entityName)
        if let sortDescriptors = sortDescriptor {
            req.sortDescriptors = sortDescriptors
        }
        req.predicate = predicate
        req.fetchLimit = count ?? 50
        req.fetchOffset = offset ?? 0
        let totalCount = (try? context?.count(for: req)) ?? 0
        let objects = (try? context?.fetch(req)) ?? []
        return (objects, totalCount)
    }
}
