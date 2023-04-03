//
//  CDForwardInfo+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDForwardInfo {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDForwardInfo> {
        NSFetchRequest<CDForwardInfo>(entityName: "CDForwardInfo")
    }

    static let entityName = "CDForwardInfo"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDForwardInfo {
        CDForwardInfo(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var messageId: NSNumber?
    @NSManaged var conversation: CDConversation?
    @NSManaged var message: CDMessage?
    @NSManaged var participant: CDParticipant?
}

public extension CDForwardInfo {
    var codable: ForwardInfo {
        ForwardInfo(conversation: conversation?.codable(), participant: participant?.codable)
    }
}
