//
//  CDContact+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDContact {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDContact> {
        NSFetchRequest<CDContact>(entityName: "CDContact")
    }

    static let entityName = "CDContact"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDContact {
        CDContact(entity: entityDescription(context), insertInto: context)
    }

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
    func update(_ contact: Contact) {
        blocked = contact.blocked as? NSNumber
        cellphoneNumber = contact.cellphoneNumber
        email = contact.email
        firstName = contact.firstName
        hasUser = contact.hasUser as NSNumber?
        id = contact.id as? NSNumber
        image = contact.image
        lastName = contact.lastName
        notSeenDuration = contact.notSeenDuration as? NSNumber
        time = contact.time as? NSNumber
        userId = contact.userId as? NSNumber
    }

    var codable: Contact {
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
