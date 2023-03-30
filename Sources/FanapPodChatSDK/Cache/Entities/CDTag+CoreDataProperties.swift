//
//  CDTag+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDTag {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDTag> {
        NSFetchRequest<CDTag>(entityName: "CDTag")
    }

    static let entityName = "CDTag"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDTag {
        CDTag(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var active: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var tagParticipants: NSSet?
}

// MARK: Generated accessors for tagParticipants

public extension CDTag {
    @objc(addTagParticipantsObject:)
    @NSManaged func addToTagParticipants(_ value: CDTagParticipant)

    @objc(removeTagParticipantsObject:)
    @NSManaged func removeFromTagParticipants(_ value: CDTagParticipant)

    @objc(addTagParticipants:)
    @NSManaged func addToTagParticipants(_ values: NSSet)

    @objc(removeTagParticipants:)
    @NSManaged func removeFromTagParticipants(_ values: NSSet)
}

public extension CDTag {
    func update(_ tag: Tag) {
        id = tag.id as NSNumber
        name = tag.name
        active = tag.active as NSNumber
    }

    var codable: Tag {
        Tag(id: id?.intValue ?? -1,
            name: name ?? "",
            active: active?.boolValue ?? false,
            tagParticipants: nil)
    }
}
