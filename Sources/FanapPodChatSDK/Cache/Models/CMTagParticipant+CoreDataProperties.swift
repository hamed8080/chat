//
// CMTagParticipant+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMTagParticipant {
    @NSManaged var id: NSNumber?
    @NSManaged var active: NSNumber?
    @NSManaged var tagId: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var conversation: CMConversation?
}
