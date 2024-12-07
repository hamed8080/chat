//
// CDQueueOfFileMessages+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDQueueOfFileMessages {
    typealias Entity = CDQueueOfFileMessages
    typealias Model = QueueOfFileMessages
    typealias Id = NSNumber
    static let name = "CDQueueOfFileMessages"
    static let queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDQueueOfFileMessages {
    @NSManaged var fileExtension: String?
    @NSManaged var fileName: String?
    @NSManaged var fileToSend: Data?
    @NSManaged var hC: NSNumber?
    @NSManaged var imageToSend: Data?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var mimeType: String?
    @NSManaged var originalName: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
    @NSManaged var userGroupHash: String?
    @NSManaged var wC: NSNumber?
    @NSManaged var xC: NSNumber?
    @NSManaged var yC: NSNumber?
}

public extension CDQueueOfFileMessages {
    func update(_ model: Model) {
        fileExtension = model.fileExtension ?? fileExtension
        fileName = model.fileName ?? fileName
        fileToSend = model.fileToSend ?? fileToSend
        imageToSend = model.imageToSend ?? imageToSend
        isPublic = model.isPublic as? NSNumber ?? isPublic
        messageType = model.messageType?.rawValue as? NSNumber ?? messageType
        metadata = model.metadata ?? metadata
        mimeType = model.mimeType ?? mimeType
        originalName = model.originalName ?? originalName
        repliedTo = model.repliedTo as? NSNumber ?? repliedTo
        textMessage = model.textMessage ?? textMessage
        threadId = model.threadId as? NSNumber ?? threadId
        typeCode = model.typeCode ?? typeCode
        uniqueId = model.uniqueId ?? uniqueId
        userGroupHash = model.userGroupHash ?? userGroupHash
        hC = model.hC as? NSNumber ?? hC
        wC = model.wC as? NSNumber ?? wC
        xC = model.xC as? NSNumber ?? xC
        yC = model.yC as? NSNumber ?? yC
    }

    var codable: Model {
        QueueOfFileMessages(fileExtension: fileExtension,
                            fileName: fileName,
                            isPublic: isPublic?.boolValue,
                            messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            mimeType: mimeType,
                            originalName: originalName,
                            repliedTo: repliedTo?.intValue,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId,
                            userGroupHash: userGroupHash,
                            hC: hC?.intValue,
                            wC: wC?.intValue,
                            xC: xC?.intValue,
                            yC: yC?.intValue,
                            fileToSend: fileToSend,
                            imageToSend: imageToSend)
    }
}
