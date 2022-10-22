//
// QueueOfFileMessages+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension QueueOfFileMessages {
    @NSManaged var textMessage: String?
    @NSManaged var fileExtension: String?
    @NSManaged var fileName: String?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var mimeType: String?
    @NSManaged var originalName: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var userGroupHash: String?
    @NSManaged var xC: NSNumber?
    @NSManaged var yC: NSNumber?
    @NSManaged var hC: NSNumber?
    @NSManaged var wC: NSNumber?

    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?

    @NSManaged var fileToSend: NSData?
    @NSManaged var imageToSend: NSData?
}
