//
//  CMConversation+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMConversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMConversation> {
        return NSFetchRequest<CMConversation>(entityName: "CMConversation")
    }

    @NSManaged public var admin:        NSNumber?
    @NSManaged public var canEditInfo:  NSNumber?
    @NSManaged public var canSpam:      NSNumber?
    @NSManaged public var closedThread: NSNumber?
    @NSManaged public var descriptions: String?
    @NSManaged public var group:        NSNumber?
    @NSManaged public var id:           NSNumber?
    @NSManaged public var image:        String?
    @NSManaged public var joinDate:     NSNumber?
    @NSManaged public var lastMessage:  String?
    @NSManaged public var lastParticipantImage: String?
    @NSManaged public var lastParticipantName:  String?
    @NSManaged public var lastSeenMessageId:    NSNumber?
    @NSManaged public var lastSeenMessageNanos: NSNumber?
    @NSManaged public var lastSeenMessageTime:  NSNumber?
    @NSManaged public var mentioned:            NSNumber?
    @NSManaged public var metadata:             String?
    @NSManaged public var mute:                 NSNumber?
    @NSManaged public var participantCount:     NSNumber?
    @NSManaged public var partner:              NSNumber?
    @NSManaged public var partnerLastDeliveredMessageId:    NSNumber?
    @NSManaged public var partnerLastDeliveredMessageNanos: NSNumber?
    @NSManaged public var partnerLastDeliveredMessageTime:  NSNumber?
    @NSManaged public var partnerLastSeenMessageId:         NSNumber?
    @NSManaged public var partnerLastSeenMessageNanos:      NSNumber?
    @NSManaged public var partnerLastSeenMessageTime:       NSNumber?
    @NSManaged public var pin:          NSNumber?
    @NSManaged public var time:         NSNumber?
    @NSManaged public var title:        String?
    @NSManaged public var type:         NSNumber?
    @NSManaged public var unreadCount:  NSNumber?
    @NSManaged public var userGroupHash: String?
    
    @NSManaged public var dummyForwardInfo: CMForwardInfo?
    @NSManaged public var dummyMessage:     NSSet?
    @NSManaged public var dummyUserRoles:   NSSet?
    @NSManaged public var inviter:          CMParticipant?
    @NSManaged public var lastMessageVO:    CMMessage?
    @NSManaged public var participants:     NSOrderedSet?
    @NSManaged public var pinMessage:       CMPinMessage?

}

// MARK: Generated accessors for dummyMessage
extension CMConversation {

    @objc(addDummyMessageObject:)
    @NSManaged public func addToDummyMessage(_ value: CMMessage)

    @objc(removeDummyMessageObject:)
    @NSManaged public func removeFromDummyMessage(_ value: CMMessage)

    @objc(addDummyMessage:)
    @NSManaged public func addToDummyMessage(_ values: NSSet)

    @objc(removeDummyMessage:)
    @NSManaged public func removeFromDummyMessage(_ values: NSSet)

}

// MARK: Generated accessors for dummyUserRoles
extension CMConversation {

    @objc(addDummyUserRolesObject:)
    @NSManaged public func addToDummyUserRoles(_ value: CMUserRole)

    @objc(removeDummyUserRolesObject:)
    @NSManaged public func removeFromDummyUserRoles(_ value: CMUserRole)

    @objc(addDummyUserRoles:)
    @NSManaged public func addToDummyUserRoles(_ values: NSSet)

    @objc(removeDummyUserRoles:)
    @NSManaged public func removeFromDummyUserRoles(_ values: NSSet)

}

// MARK: Generated accessors for participants
extension CMConversation {

    @objc(insertObject:inParticipantsAtIndex:)
    @NSManaged public func insertIntoParticipants(_ value: CMParticipant, at idx: Int)

    @objc(removeObjectFromParticipantsAtIndex:)
    @NSManaged public func removeFromParticipants(at idx: Int)

    @objc(insertParticipants:atIndexes:)
    @NSManaged public func insertIntoParticipants(_ values: [CMParticipant], at indexes: NSIndexSet)

    @objc(removeParticipantsAtIndexes:)
    @NSManaged public func removeFromParticipants(at indexes: NSIndexSet)

    @objc(replaceObjectInParticipantsAtIndex:withObject:)
    @NSManaged public func replaceParticipants(at idx: Int, with value: CMParticipant)

    @objc(replaceParticipantsAtIndexes:withParticipants:)
    @NSManaged public func replaceParticipants(at indexes: NSIndexSet, with values: [CMParticipant])

    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: CMParticipant)

    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: CMParticipant)

    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: NSOrderedSet)

    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: NSOrderedSet)

}
