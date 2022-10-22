//
// CMReplyInfo+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension CMReplyInfo {
    @NSManaged var messageId: NSNumber?
    @NSManaged var deletedd: NSNumber?
    @NSManaged var message: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedToMessageId: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var time: NSNumber?
    @NSManaged var dummyMessage: CMMessage?
    @NSManaged var participant: CMParticipant?
}
