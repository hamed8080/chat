//
// QueueOfEditMessages+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension QueueOfEditMessages {
    static let crud = CoreDataCrud<QueueOfEditMessages>(entityName: "QueueOfEditMessages")

    func getCodable() -> EditMessageRequest? {
        guard let threadId = threadId as? Int, let messageId = messageId as? Int, let textMessage = textMessage, let messageType = messageType as? Int else { return nil }
        return EditMessageRequest(
            threadId: threadId,
            messageType: MessageType(rawValue: messageType) ?? .text,
            messageId: messageId,
            textMessage: textMessage,
            repliedTo: repliedTo as? Int,
            metadata: metadata
        )
    }

    class func convertToCM(request: EditMessageRequest, entity: QueueOfEditMessages? = nil) -> QueueOfEditMessages {
        let model = entity ?? QueueOfEditMessages()
        model.threadId = request.threadId as NSNumber?
        model.messageId = request.messageId as NSNumber?
        model.messageType = request.messageType.rawValue as NSNumber?
        model.textMessage = request.textMessage
        model.repliedTo = request.repliedTo as NSNumber?
        model.typeCode = request.typeCode
        model.uniqueId = request.uniqueId
        model.metadata = request.metadata

        return model
    }

    class func insert(request: EditMessageRequest, resultEntity: ((QueueOfEditMessages) -> Void)? = nil) {
        if let entity = QueueOfEditMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
            resultEntity?(entity)
            return
        }

        QueueOfEditMessages.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
}
