//
//  Contact+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Contact: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked) as? NSNumber
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        image = try container.decodeIfPresent(String.self, forKey: .image)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        notSeenDuration = try container.decodeIfPresent(Int.self, forKey: .notSeenDuration) as? NSNumber
        time = try container.decodeIfPresent(UInt.self, forKey: .timeStamp) as? NSNumber
        userId = try container.decodeIfPresent(Int.self, forKey: .userId) as? NSNumber
        hasUser = (try container.decodeIfPresent(Bool.self, forKey: .hasUser) ?? false) as NSNumber?
        let linkedUser = try container.decodeIfPresent(User.self, forKey: .linkedUser)
        if linkedUser != nil {
            hasUser = true
        }
    }
}

public extension Contact {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    convenience init(
        context: NSManagedObjectContext,
        blocked: Bool? = nil,
        cellphoneNumber: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        hasUser: Bool,
        id: Int? = nil,
        image: String? = nil,
        lastName: String? = nil,
        linkedUser _: User? = nil,
        notSeenDuration: Int? = nil,
        timeStamp: UInt? = nil,
        userId: Int? = nil
    ) {
        self.init(context: context)
        self.blocked = blocked as? NSNumber
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.hasUser = hasUser as NSNumber?
        self.id = id as? NSNumber
        self.image = image
        self.lastName = lastName
        self.notSeenDuration = notSeenDuration as? NSNumber
        time = timeStamp as? NSNumber
        self.userId = userId as? NSNumber
    }

    private enum CodingKeys: String, CodingKey {
        case blocked
        case cellphoneNumber
        case email
        case firstName
        case lastName
        case hasUser
        case id
        case image = "profileImage"
        case linkedUser
        case notSeenDuration
        case timeStamp
        case userId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(blocked as? Bool, forKey: .blocked)
        try container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(hasUser as? Bool, forKey: .hasUser)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(notSeenDuration as? Int, forKey: .notSeenDuration)
        try container.encodeIfPresent(time as? Int, forKey: .timeStamp)
        try container.encodeIfPresent(userId as? Int, forKey: .userId)
    }
}

/// Core Data Queries and functions
public extension CMContact {
//    static let crud = CoreDataCrud<CMContact>(entityName: "CMContact")
//
//    func getCodable() -> Contact {
//        Contact(blocked: blocked as? Bool,
//                cellphoneNumber: cellphoneNumber,
//                email: email,
//                firstName: firstName,
//                hasUser: (hasUser as? Bool) ?? false,
//                id: id as? Int,
//                image: image,
//                lastName: lastName,
//                linkedUser: linkedUser?.getCodable(),
//                notSeenDuration: notSeenDuration as? Int,
//                timeStamp: time as? UInt,
//                userId: userId as? Int)
//    }
//
//    internal class func convertContactToCM(contact: Contact, entity: CMContact? = nil) -> CMContact {
//        let model = entity ?? CMContact()
//        model.blocked = contact.blocked as NSNumber?
//        model.cellphoneNumber = contact.cellphoneNumber
//        model.email = contact.email
//        model.firstName = contact.firstName
//        model.lastName = contact.lastName
//        model.hasUser = contact.hasUser as NSNumber?
//        model.id = contact.id as NSNumber?
//        model.image = contact.image
//        if let linkedUser = contact.linkedUser {
//            CMLinkedUser.insertOrUpdate(linkedUser: linkedUser, resultEntity: { linkedUserEntity in
//                model.linkedUser = linkedUserEntity
//            })
//        }
//        model.notSeenDuration = contact.notSeenDuration as NSNumber?
//        model.time = contact.timeStamp as NSNumber?
//        model.userId = contact.userId as NSNumber?
//        return model
//    }
//
//    class func deleteContacts(byTimeStamp timeStamp: Int, logger: Logger? = nil) {
//        let currentTime = Int(Date().timeIntervalSince1970)
//        let predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
//        CMContact.crud.deleteWith(predicate: predicate, logger)
//    }
//
//    class func insertOrUpdate(contacts: [Contact]) {
//        contacts.forEach { contact in
//            if let findedEntity = CMContact.crud.find(keyWithFromat: "id == %i", value: contact.id!) {
//                _ = convertContactToCM(contact: contact, entity: findedEntity)
//            } else {
//                CMContact.crud.insert { cmContactEntity in
//                    _ = convertContactToCM(contact: contact, entity: cmContactEntity)
//                }
//            }
//        }
//    }
//
    class func getContacts(req: ContactsRequest?) -> [Contact] {
        guard let req = req else { return [] }
        let fetchRequest = Contact.fetchRequest()
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
        fetchRequest.fetchLimit = req.size
        fetchRequest.fetchOffset = req.offset
        let contacts = CMContact.crud.fetchWith(fetchRequest)?.map { $0.getCodable() }
        return contacts ?? []
    }
}
