//
// QueueOfTextMessages+extenstions copy.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public extension QueueOfTextMessages {
    static let crud = CoreDataCrud<QueueOfTextMessages>(entityName: "QueueOfTextMessages")

    func getCodable() -> SendTextMessageRequest? {
        guard let threadId = threadId as? Int, let textMessage = textMessage, let messageType = messageType as? Int else { return nil }
        return SendTextMessageRequest(threadId: threadId,
                                      textMessage: textMessage,
                                      messageType: MessageType(rawValue: messageType) ?? .text,
                                      metadata: metadata,
                                      repliedTo: repliedTo as? Int,
                                      systemMetadata: systemMetadata,
                                      uniqueId: uniqueId)
    }

    class func convertToCM(request: SendTextMessageRequest, entity: QueueOfTextMessages? = nil) -> QueueOfTextMessages {
        let model = entity ?? QueueOfTextMessages()
        model.threadId = request.threadId as NSNumber?
        model.messageType = request.messageType.rawValue as NSNumber?
        model.textMessage = request.textMessage
        model.repliedTo = request.repliedTo as NSNumber?
        model.typeCode = request.typeCode
        model.uniqueId = request.uniqueId
        model.systemMetadata = request.systemMetadata
        model.metadata = request.metadata

        return model
    }

    class func insert(request: SendTextMessageRequest, resultEntity: ((QueueOfTextMessages) -> Void)? = nil) {
        if let entity = QueueOfTextMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
            resultEntity?(entity)
            return
        }
        QueueOfTextMessages.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
}
