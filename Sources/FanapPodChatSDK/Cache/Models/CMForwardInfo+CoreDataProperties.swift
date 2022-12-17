//
// CMForwardInfo+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension CMForwardInfo {
    @NSManaged var messageId: NSNumber?
    @NSManaged var conversation: CMConversation?
    @NSManaged var dummyMessage: CMMessage?
    @NSManaged var participant: CMParticipant?
}
