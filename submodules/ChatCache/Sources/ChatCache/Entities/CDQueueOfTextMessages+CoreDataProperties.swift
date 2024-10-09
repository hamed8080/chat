//
// CDQueueOfTextMessages+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDQueueOfTextMessages {
    typealias Entity = CDQueueOfTextMessages
    typealias Model = QueueOfTextMessages
    typealias Id = NSNumber
    static let name = "CDQueueOfTextMessages"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDQueueOfTextMessages {
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}

public extension CDQueueOfTextMessages {
    func update(_ model: Model) {
        messageType = model.messageType?.rawValue as? NSNumber ?? messageType
        metadata = model.metadata ?? metadata
        repliedTo = model.repliedTo as? NSNumber ?? repliedTo
        systemMetadata = model.systemMetadata ?? systemMetadata
        textMessage = model.textMessage ?? textMessage
        threadId = model.threadId as? NSNumber ?? threadId
        typeCode = model.typeCode ?? typeCode
        uniqueId = model.uniqueId ?? uniqueId
    }

    var codable: Model {
        QueueOfTextMessages(messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            repliedTo: repliedTo?.intValue,
                            systemMetadata: systemMetadata,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId)
    }
}
