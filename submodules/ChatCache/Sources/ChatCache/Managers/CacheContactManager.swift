//
// CacheContactManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheContactManager: BaseCoreDataManager<CDContact>, @unchecked Sendable {

    public func insertContacts(models: [Contact]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            models.forEach { contact in
                let req = Entity.fetchRequest()
                req.fetchLimit = 1
                req.predicate = idPredicate(id: contact.id?.nsValue ?? -1)
                if let cdContact = try? viewContext.fetch(req).first {
                    cdContact.firstName = contact.firstName
                    cdContact.lastName = contact.lastName
                    cdContact.email = contact.email
                    cdContact.image = contact.image
                    cdContact.cellphoneNumber = contact.cellphoneNumber
                    saveViewContext()
                } else {
                    insert(models: [contact])
                }
            }
        }
    }

    public func block(_ block: Bool, _ contactId: Int) {
        let predicate = idPredicate(id: contactId.nsValue)
        let propertiesToUpdate: [String: Any] = ["blocked": block]
        update(propertiesToUpdate, predicate)
    }

    public func getContacts(_ req: FetchContactsRequest, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        let fetchRequest = Entity.fetchRequest()
        let ascending = req.order != Ordering.desc.rawValue
        if let id = req.id {
            fetchRequest.predicate = NSPredicate(format: "\(Entity.idName) == \(Entity.queryIdSpecifier)", id.nsValue)
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
        
        let notSeenDurationSort = NSSortDescriptor(key: "notSeenDuration", ascending: false)
        let hasUserSort = NSSortDescriptor(key: "hasUser", ascending: false)
        let firstNameSort = NSSortDescriptor(key: "firstName", ascending: ascending)
        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: ascending)
        fetchRequest.sortDescriptors = [notSeenDurationSort, hasUserSort, lastNameSort, firstNameSort]
        DispatchQueue.main.async {
            self.viewContext.perform {
                let count = try self.viewContext.count(for: Entity.fetchRequest())
                fetchRequest.fetchLimit = req.size
                fetchRequest.fetchOffset = req.offset
                let contacts = try self.viewContext.fetch(fetchRequest)
                completion(contacts, count)
            }
        }
    }
}
