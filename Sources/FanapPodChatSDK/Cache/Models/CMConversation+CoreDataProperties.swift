//
// CMConversation+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMConversation {
    @NSManaged var admin: NSNumber?
    @NSManaged var canEditInfo: NSNumber?
    @NSManaged var canSpam: NSNumber?
    @NSManaged var closedThread: NSNumber?
    @NSManaged var descriptions: String?
    @NSManaged var group: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var joinDate: NSNumber?
    @NSManaged var lastMessage: String?
    @NSManaged var lastParticipantImage: String?
    @NSManaged var lastParticipantName: String?
    @NSManaged var lastSeenMessageId: NSNumber?
    @NSManaged var lastSeenMessageNanos: NSNumber?
    @NSManaged var lastSeenMessageTime: NSNumber?
    @NSManaged var mentioned: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var mute: NSNumber?
    @NSManaged var participantCount: NSNumber?
    @NSManaged var partner: NSNumber?
    @NSManaged var partnerLastDeliveredMessageId: NSNumber?
    @NSManaged var partnerLastDeliveredMessageNanos: NSNumber?
    @NSManaged var partnerLastDeliveredMessageTime: NSNumber?
    @NSManaged var partnerLastSeenMessageId: NSNumber?
    @NSManaged var partnerLastSeenMessageNanos: NSNumber?
    @NSManaged var partnerLastSeenMessageTime: NSNumber?
    @NSManaged var pin: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var title: String?
    @NSManaged var type: NSNumber?
    @NSManaged var unreadCount: NSNumber?
    @NSManaged var userGroupHash: String?
    @NSManaged var dummyForwardInfo: CMForwardInfo?
    @NSManaged var dummyMessage: NSSet?
    @NSManaged var dummyUserRoles: NSSet?
    @NSManaged var inviter: CMParticipant?
    @NSManaged var lastMessageVO: CMMessage?
    @NSManaged var participants: NSOrderedSet?
    @NSManaged var pinMessage: CMPinMessage?
    @NSManaged var isArchive: NSNumber?
}

// MARK: Generated accessors for dummyMessage

public extension CMConversation {
    @objc(addDummyMessageObject:)
    @NSManaged func addToDummyMessage(_ value: CMMessage)

    @objc(removeDummyMessageObject:)
    @NSManaged func removeFromDummyMessage(_ value: CMMessage)

    @objc(addDummyMessage:)
    @NSManaged func addToDummyMessage(_ values: NSSet)

    @objc(removeDummyMessage:)
    @NSManaged func removeFromDummyMessage(_ values: NSSet)
}

// MARK: Generated accessors for dummyUserRoles

public extension CMConversation {
    @objc(addDummyUserRolesObject:)
    @NSManaged func addToDummyUserRoles(_ value: CMUserRole)

    @objc(removeDummyUserRolesObject:)
    @NSManaged func removeFromDummyUserRoles(_ value: CMUserRole)

    @objc(addDummyUserRoles:)
    @NSManaged func addToDummyUserRoles(_ values: NSSet)

    @objc(removeDummyUserRoles:)
    @NSManaged func removeFromDummyUserRoles(_ values: NSSet)
}

// MARK: Generated accessors for participants

public extension CMConversation {
    @objc(insertObject:inParticipantsAtIndex:)
    @NSManaged func insertIntoParticipants(_ value: CMParticipant, at idx: Int)

    @objc(removeObjectFromParticipantsAtIndex:)
    @NSManaged func removeFromParticipants(at idx: Int)

    @objc(insertParticipants:atIndexes:)
    @NSManaged func insertIntoParticipants(_ values: [CMParticipant], at indexes: NSIndexSet)

    @objc(removeParticipantsAtIndexes:)
    @NSManaged func removeFromParticipants(at indexes: NSIndexSet)

    @objc(replaceObjectInParticipantsAtIndex:withObject:)
    @NSManaged func replaceParticipants(at idx: Int, with value: CMParticipant)

    @objc(replaceParticipantsAtIndexes:withParticipants:)
    @NSManaged func replaceParticipants(at indexes: NSIndexSet, with values: [CMParticipant])

    @objc(addParticipantsObject:)
    @NSManaged func addToParticipants(_ value: CMParticipant)

    @objc(removeParticipantsObject:)
    @NSManaged func removeFromParticipants(_ value: CMParticipant)

    @objc(addParticipants:)
    @NSManaged func addToParticipants(_ values: NSOrderedSet)

    @objc(removeParticipants:)
    @NSManaged func removeFromParticipants(_ values: NSOrderedSet)
}
