//
//  CMConversation+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMConversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMConversation> {
        return NSFetchRequest<CMConversation>(entityName: "CMConversation")
    }

    @NSManaged public var admin: NSNumber?
    @NSManaged public var canEditInfo: NSNumber?
    @NSManaged public var canSpam: NSNumber?
    @NSManaged public var descriptions: String?
    @NSManaged public var group: NSNumber?
    @NSManaged public var id: NSNumber?
    @NSManaged public var image: String?
    @NSManaged public var joinDate: NSNumber?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastParticipantImage: String?
    @NSManaged public var lastParticipantName: String?
    @NSManaged public var lastSeenMessageId: NSNumber?
    @NSManaged public var metadata: String?
    @NSManaged public var mute: NSNumber?
    @NSManaged public var participantCount: NSNumber?
    @NSManaged public var partner: NSNumber?
    @NSManaged public var partnerLastDeliveredMessageId: NSNumber?
    @NSManaged public var partnerLastSeenMessageId: NSNumber?
    @NSManaged public var time: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var unreadCount: NSNumber?
    @NSManaged public var inviter: CMParticipant?
    @NSManaged public var lastMessageVO: CMMessage?
    @NSManaged public var participants: [CMParticipant]?

}

// MARK: Generated accessors for participants
extension CMConversation {

    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: CMParticipant)

    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: CMParticipant)

    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: NSSet)

    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: NSSet)

}
