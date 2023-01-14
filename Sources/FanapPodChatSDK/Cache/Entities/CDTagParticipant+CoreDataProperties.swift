//
//  CDTagParticipant+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDTagParticipant {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDTagParticipant> {
        NSFetchRequest<CDTagParticipant>(entityName: "CDTagParticipant")
    }

    @NSManaged var active: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var tagId: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var conversation: CDConversation?
    @NSManaged var tag: CDTag?
}

public extension CDTagParticipant {
    func update(_ tagParticipant: TagParticipant) {
        id = tagParticipant.id as? NSNumber
        active = tagParticipant.active as? NSNumber
        tagId = tagParticipant.tagId as? NSNumber
        id = tagParticipant.id as? NSNumber
    }

    var codable: TagParticipant {
        TagParticipant(id: id?.intValue,
                       active: active?.boolValue,
                       tagId: tagId?.intValue,
                       threadId: threadId?.intValue,
                       conversation: conversation?.codable)
    }
}
