//
// CoreDataCrud.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

open class CoreDataCrud<T: NSFetchRequestResult> {
    var entityName: String
    var context: NSManagedObjectContext

    public init(context: NSManagedObjectContext, entityName: String) {
        self.context = context
        self.entityName = entityName
    }

    public func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        NSFetchRequest(entityName: entityName)
    }

    public func getInsertEntity() -> T? {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T
    }

    public func getFetchRequest() -> NSFetchRequest<T> {
        NSFetchRequest<T>(entityName: entityName)
    }

    public func getAll() -> [T] {
        (try? context.fetch(getFetchRequest())) ?? []
    }

    public func getTotalCount(predicate: NSPredicate? = nil) -> Int {
        let req = fetchRequest()
        req.predicate = predicate
        return (try? context.count(for: req)) ?? 0
    }

    public func fetchWith(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [T]? {
        (try? context.fetch(fetchRequest)) as? [T]
    }

    public func fetchWith(_ predicate: NSPredicate) -> [T]? {
        let req = fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) as? [T]
    }

    /// - todo: check key equality work with @ for string or int %i float %f and ...
    public func find(keyWithFromat: String, value: CVarArg) -> T? {
        let req = getFetchRequest()
        req.predicate = NSPredicate(format: "\(keyWithFromat)", value)
        do {
            return try context.fetch(req).first
        } catch {
            return nil
        }
    }

    public func delete(entity: NSManagedObject) {
        context.delete(entity)
    }

    public func deleteEntityWithPredicate(predicate: NSPredicate) {
        if let entity = fetchWith(predicate)?.first as? NSManagedObject {
            delete(entity: entity)
        }
    }

    public func deleteWith(predicate: NSPredicate, _ logger: Logger?) {
        do {
            let req = fetchRequest()
            req.predicate = predicate
            let deleteReq = NSBatchDeleteRequest(fetchRequest: req)
            try context.execute(deleteReq)
            logger?.log(title: "CHAT_SDK:", message: "saved successfully from deleteWith execute")
        } catch {
            logger?.log(title: "error in deleteWith happened", message: "\(error)")
        }
    }

    public func deleteAll(_ logger: Logger?) {
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest())
            deleteRequest.resultType = .resultTypeObjectIDs
            let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deletedResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deletedResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
            logger?.log(title: "saved successfully from deleteAll execute for table \(entityName)")
        } catch {
            logger?.log(title: "error in deleteAll happened", message: "\(error)")
        }
    }

    public func insert(setEntityVariables: @escaping (T) -> Void) {
        insertAll(setEntityVariables: setEntityVariables)
    }

    /// - warning: Please be sure using entity fetched from insertEntity method otherwise cant save
    public func insertAll(setEntityVariables: @escaping (T) -> Void) {
        context.perform { [weak self] in
            if let entity = self?.getInsertEntity() {
                setEntityVariables(entity)
            }
        }
    }

    public func fetchWithOffset(count: Int?, offset: Int?, predicate: NSPredicate?, sortDescriptor: [NSSortDescriptor]? = nil) -> [T] {
        let req = fetchRequest()
        if let sortDescriptors = sortDescriptor {
            req.sortDescriptors = sortDescriptors
        }
        req.predicate = predicate
        req.fetchLimit = count ?? 50
        req.fetchOffset = offset ?? 0
        return fetchWith(req) ?? []
    }
}
