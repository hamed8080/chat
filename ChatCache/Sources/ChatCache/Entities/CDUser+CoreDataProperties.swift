//
//  CDUser+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatModels

public extension CDUser {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDUser> {
        NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    static let entityName = "CDUser"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDUser {
        CDUser(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var bio: String?
    @NSManaged var cellphoneNumber: String?
    @NSManaged var coreUserId: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var isMe: NSNumber?
    @NSManaged var lastName: String?
    @NSManaged var lastSeen: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var name: String?
    @NSManaged var nickname: String?
    @NSManaged var receiveEnable: NSNumber?
    @NSManaged var sendEnable: NSNumber?
    @NSManaged var ssoId: String?
    @NSManaged var username: String?
    @NSManaged var contacts: NSSet?
    @NSManaged var roles: NSSet?
}

// MARK: Generated accessors for contacts

public extension CDUser {
    @objc(addContactsObject:)
    @NSManaged func addToContacts(_ value: CDContact)

    @objc(removeContactsObject:)
    @NSManaged func removeFromContacts(_ value: CDContact)

    @objc(addContacts:)
    @NSManaged func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged func removeFromContacts(_ values: NSSet)
}

// MARK: Generated accessors for roles

public extension CDUser {
    @objc(addRolesObject:)
    @NSManaged func addToRoles(_ value: CDUserRole)

    @objc(removeRolesObject:)
    @NSManaged func removeFromRoles(_ value: CDUserRole)

    @objc(addRoles:)
    @NSManaged func addToRoles(_ values: NSSet)

    @objc(removeRoles:)
    @NSManaged func removeFromRoles(_ values: NSSet)
}

public extension CDUser {
    func update(_ user: User) {
        cellphoneNumber = user.cellphoneNumber
        coreUserId = user.coreUserId as? NSNumber
        email = user.email
        id = user.id as? NSNumber
        image = user.image
        lastSeen = user.lastSeen as? NSNumber
        name = user.name
        nickname = user.nickname
        receiveEnable = user.receiveEnable as? NSNumber
        sendEnable = user.sendEnable as? NSNumber
        username = user.username
        bio = user.chatProfileVO?.bio
        metadata = user.chatProfileVO?.metadata
        ssoId = user.ssoId
        lastName = user.lastName
        firstName = user.firstName
    }

    var codable: User {
        User(cellphoneNumber: cellphoneNumber,
             coreUserId: coreUserId?.intValue,
             email: email,
             id: id?.intValue,
             image: image,
             lastSeen: lastSeen?.intValue,
             name: name,
             nickname: nickname,
             receiveEnable: receiveEnable?.boolValue,
             sendEnable: sendEnable?.boolValue,
             username: username,
             ssoId: ssoId,
             firstName: firstName,
             lastName: lastName, profile: Profile(bio: bio, metadata: metadata))
    }
}
