//
// QueueOfForwardMessages+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension QueueOfForwardMessages {
    @NSManaged var messageIds: String?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var fromThreadId: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueIds: String?
}
