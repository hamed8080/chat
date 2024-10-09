//
// CDQueueOfEditMessages+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDQueueOfEditMessages {
    typealias Entity = CDQueueOfEditMessages
    typealias Model = QueueOfEditMessages
    typealias Id = NSNumber
    static let name = "CDQueueOfEditMessages"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDQueueOfEditMessages {
    @NSManaged var messageId: NSNumber?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}

public extension CDQueueOfEditMessages {
    func update(_ model: Model) {
        messageId = model.messageId as? NSNumber ?? messageId
        messageType = model.messageType?.rawValue as? NSNumber ?? messageType
        metadata = model.metadata ?? metadata
        repliedTo = model.repliedTo as? NSNumber ?? repliedTo
        textMessage = model.textMessage ?? textMessage
        threadId = model.threadId as? NSNumber ?? threadId
        typeCode = model.typeCode ?? typeCode
        uniqueId = model.uniqueId ?? uniqueId
    }

    var codable: Model {
        QueueOfEditMessages(messageId: messageId?.intValue,
                            messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            repliedTo: repliedTo?.intValue,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId)
    }
}
