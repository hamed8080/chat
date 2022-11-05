//
// QueueOfTextMessages+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension QueueOfTextMessages {
    @NSManaged var textMessage: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
    @NSManaged var metadata: String?
    @NSManaged var systemMetadata: String?
}
