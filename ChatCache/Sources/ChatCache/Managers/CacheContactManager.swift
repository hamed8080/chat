//
//  CacheContactManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger
import ChatModels
import ChatDTO

public final class CacheContactManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Contact) {
        let entity = CDContact.insertEntity(context)
        entity.update(model)
    }

    public func insert(models: [Contact]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDContact?) -> Void) {
        context.perform {
            let req = CDContact.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let contact = try self.context.fetch(req).first
            completion(contact)
        }
    }

    public func find(predicate: NSPredicate, _ completion: @escaping ([CDContact]) -> Void) {
        context.perform {
            let req = CDContact.fetchRequest()
            req.predicate = predicate
            let contacts = try self.context.fetch(req)
            completion(contacts)
        }
    }

    func update(model _: Contact, entity _: CDContact) {}

    func update(models _: [Contact]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDContact.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDContact) {}

    public func delete(_ id: Int) {
        batchDelete(context, entityName: CDContact.entityName, predicate: idPredicate(id: id))
    }

    public func block(_ block: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["blocked": block]
        update(propertiesToUpdate, predicate)
    }

    public func getContacts(_ req: ContactsRequest?, _ completion: @escaping ([CDContact], Int) -> Void) {
        guard let req = req else { completion([], 0); return }
        let fetchRequest = CDContact.fetchRequest()
        let ascending = req.order != Ordering.desc.rawValue
        if let id = req.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        } else if req.isAutoGenratedUniqueId == false {
            fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", req.uniqueId)
        } else {
            var andPredicateArr = [NSPredicate]()

            if let cellphoneNumber = req.cellphoneNumber, cellphoneNumber != "" {
                andPredicateArr.append(NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@", cellphoneNumber))
            }
            if let email = req.email, email != "" {
                andPredicateArr.append(NSPredicate(format: "email CONTAINS[cd] %@", email))
            }

            var orPredicatArray = [NSPredicate]()

            if andPredicateArr.count > 0 {
                orPredicatArray.append(NSCompoundPredicate(type: .and, subpredicates: andPredicateArr))
            }

            if let query = req.query, query != "" {
                let theSearchPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", query, query, query, query)
                orPredicatArray.append(theSearchPredicate)
            }

            if orPredicatArray.count > 0 {
                fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
            }
        }

        let firstNameSort = NSSortDescriptor(key: "firstName", ascending: ascending)
        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: ascending)
        fetchRequest.sortDescriptors = [lastNameSort, firstNameSort]
        context.perform {
            let count = try? self.context.count(for: CDContact.fetchRequest())
            fetchRequest.fetchLimit = req.size
            fetchRequest.fetchOffset = req.offset
            let contacts = try self.context.fetch(fetchRequest)
            completion(contacts, count ?? 0)
        }
    }

    public func allContacts(_ completion: @escaping ([CDContact]) -> Void) {
        context.perform {
            let req = CDContact.fetchRequest()
            let contacts = try self.context.fetch(req)
            completion(contacts)
        }
    }
}
