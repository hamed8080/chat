//
// QueueOfEditMessages+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

public extension QueueOfEditMessages {
    @NSManaged var textMessage: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var messageId: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}
