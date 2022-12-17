//
// CMParticipant+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMParticipant {
    @NSManaged var admin: NSNumber?
    @NSManaged var auditor: NSNumber?
    @NSManaged var blocked: NSNumber?
    @NSManaged var cellphoneNumber: String?
    @NSManaged var contactFirstName: String?
    @NSManaged var contactId: NSNumber?
    @NSManaged var contactName: String?
    @NSManaged var contactLastName: String?
    @NSManaged var coreUserId: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var keyId: String?
    @NSManaged var lastName: String?
    @NSManaged var myFriend: NSNumber?
    @NSManaged var name: String?
    @NSManaged var notSeenDuration: NSNumber?
    @NSManaged var online: NSNumber?
    @NSManaged var receiveEnable: NSNumber?
    @NSManaged var roles: [String]?
    @NSManaged var sendEnable: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var username: String?
    @NSManaged var bio: String?
    @NSManaged var metadata: String?
    @NSManaged var dummyConversationInviter: NSSet?
    @NSManaged var dummyConversationParticipants: NSSet?
    @NSManaged var dummyForwardInfo: CMForwardInfo?
    @NSManaged var dummyMessage: NSSet?
    @NSManaged var dummyReplyInfo: CMReplyInfo?
}

// MARK: Generated accessors for dummyConversationInviter

public extension CMParticipant {
    @objc(addDummyConversationInviterObject:)
    @NSManaged func addToDummyConversationInviter(_ value: CMConversation)

    @objc(removeDummyConversationInviterObject:)
    @NSManaged func removeFromDummyConversationInviter(_ value: CMConversation)

    @objc(addDummyConversationInviter:)
    @NSManaged func addToDummyConversationInviter(_ values: NSSet)

    @objc(removeDummyConversationInviter:)
    @NSManaged func removeFromDummyConversationInviter(_ values: NSSet)
}

// MARK: Generated accessors for dummyConversationParticipants

public extension CMParticipant {
    @objc(addDummyConversationParticipantsObject:)
    @NSManaged func addToDummyConversationParticipants(_ value: CMConversation)

    @objc(removeDummyConversationParticipantsObject:)
    @NSManaged func removeFromDummyConversationParticipants(_ value: CMConversation)

    @objc(addDummyConversationParticipants:)
    @NSManaged func addToDummyConversationParticipants(_ values: NSSet)

    @objc(removeDummyConversationParticipants:)
    @NSManaged func removeFromDummyConversationParticipants(_ values: NSSet)
}

// MARK: Generated accessors for dummyMessage

public extension CMParticipant {
    @objc(addDummyMessageObject:)
    @NSManaged func addToDummyMessage(_ value: CMMessage)

    @objc(removeDummyMessageObject:)
    @NSManaged func removeFromDummyMessage(_ value: CMMessage)

    @objc(addDummyMessage:)
    @NSManaged func addToDummyMessage(_ values: NSSet)

    @objc(removeDummyMessage:)
    @NSManaged func removeFromDummyMessage(_ values: NSSet)
}
