//
// CMMessage+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMMessage {
    @NSManaged var deletable: NSNumber?
    @NSManaged var delivered: NSNumber?
    @NSManaged var editable: NSNumber?
    @NSManaged var edited: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var mentioned: NSNumber?
    @NSManaged var message: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var ownerId: NSNumber?
    @NSManaged var pinned: NSNumber?
    @NSManaged var previousId: NSNumber?
    @NSManaged var seen: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var uniqueId: String?
    @NSManaged var conversation: CMConversation?
    @NSManaged var dummyConversationLastMessageVO: CMConversation?
    @NSManaged var forwardInfo: CMForwardInfo?
    @NSManaged var participant: CMParticipant?
    @NSManaged var replyInfo: CMReplyInfo?
}
