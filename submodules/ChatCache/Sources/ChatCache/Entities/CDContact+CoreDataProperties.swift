//
// CDContact+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDContact {
    typealias Entity = CDContact
    typealias Model = Contact
    typealias Id = NSNumber
    static let name = "CDContact"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDContact {
    @NSManaged var blocked: NSNumber?
    @NSManaged var cellphoneNumber: String?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var hasUser: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var lastName: String?
    @NSManaged var notSeenDuration: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var uniqueId: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var user: CDUser?
}

public extension CDContact {
    func update(_ model: Model) {
        blocked = model.blocked as? NSNumber ?? blocked
        cellphoneNumber = model.cellphoneNumber ?? cellphoneNumber
        email = model.email ?? email
        firstName = model.firstName ?? firstName
        hasUser = model.hasUser as NSNumber? ?? hasUser
        id = model.id as? NSNumber ?? id
        image = model.image ?? image
        lastName = model.lastName ?? lastName
        notSeenDuration = model.notSeenDuration as? NSNumber ?? notSeenDuration
        time = model.time as? NSNumber ?? time
        userId = model.userId as? NSNumber ?? userId
        setUser(model: model)
    }

    func setUser(model: Model) {
        guard let context = managedObjectContext else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDUser.id), (model.user?.id ?? 0).nsValue)
        let req = CDUser.fetchRequest()
        req.predicate = predicate
        if let userEntity = try? context.fetch(req).first {
            self.user = userEntity
        } else if let userModel = model.user {
            let userEntity = CDUser.insertEntity(context)
            userEntity.update(userModel)
            self.user = userEntity
        }
    }

    var codable: Model {
        Contact(blocked: blocked?.boolValue,
                cellphoneNumber: cellphoneNumber,
                email: email,
                firstName: firstName,
                hasUser: hasUser?.boolValue,
                id: id?.intValue,
                image: image,
                lastName: lastName,
                user: user?.codable,
                notSeenDuration: notSeenDuration?.intValue,
                time: time?.uintValue,
                userId: userId?.intValue)
    }

    func isContactChanged(contact: Contact) -> Bool {
        (email != contact.email) ||
            (firstName != contact.firstName) ||
            (lastName != contact.lastName)
    }
}
