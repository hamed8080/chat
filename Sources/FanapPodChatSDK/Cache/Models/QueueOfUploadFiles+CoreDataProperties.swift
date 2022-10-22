//
// QueueOfUploadFiles+CoreDataProperties.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
import Foundation

public extension QueueOfUploadFiles {
    @NSManaged var dataToSend: NSData?
    @NSManaged var fileExtension: String?
    @NSManaged var fileName: String?
    @NSManaged var fileSize: NSNumber?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var mimeType: String?
    @NSManaged var originalName: String?
    @NSManaged var userGroupHash: String?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}
