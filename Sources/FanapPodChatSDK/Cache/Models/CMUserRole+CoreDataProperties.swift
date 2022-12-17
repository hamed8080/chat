//
// CMUserRole+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMUserRole {
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var roles: NSObject?
    @NSManaged var conversation: NSSet?
}

// MARK: Generated accessors for conversation

public extension CMUserRole {
    @objc(addConversationObject:)
    @NSManaged func addToConversation(_ value: CMConversation)

    @objc(removeConversationObject:)
    @NSManaged func removeFromConversation(_ value: CMConversation)

    @objc(addConversation:)
    @NSManaged func addToConversation(_ values: NSSet)

    @objc(removeConversation:)
    @NSManaged func removeFromConversation(_ values: NSSet)
}
