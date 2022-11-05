//
// QueueOfForwardMessages+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension QueueOfForwardMessages {
    static let crud = CoreDataCrud<QueueOfForwardMessages>(entityName: "QueueOfForwardMessages")

    func getCodable() -> ForwardMessageRequest? {
        guard let threadId = threadId as? Int, let messageId = messageId as? Int else { return nil }
        return ForwardMessageRequest(
            threadId: threadId,
            messageId: messageId,
            uniqueId: uniqueId
        )
    }

    class func convertToCM(request: ForwardMessageRequest, messageId: Int, entity: QueueOfForwardMessages? = nil) -> QueueOfForwardMessages {
        let model = entity ?? QueueOfForwardMessages()
        model.threadId = request.threadId as NSNumber?
        model.messageId = messageId as NSNumber?
        model.repliedTo = nil
        model.typeCode = Chat.sharedInstance.config?.typeCode
        model.uniqueId = request.uniqueId

        return model
    }

    class func insert(request: ForwardMessageRequest, resultEntity: ((QueueOfForwardMessages) -> Void)? = nil) {
        for (index, messageId) in request.messageIds.enumerated() {
            if let entity = QueueOfForwardMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
                resultEntity?(entity)

            } else {
                QueueOfForwardMessages.crud.insert { cmEntity in
                    let cmEntity = convertToCM(request: request, messageId: messageId, entity: cmEntity)
                    cmEntity.uniqueId = request.uniqueIds[index]
                    resultEntity?(cmEntity)
                }
            }
        }
    }

    internal class func getCodableForwardResuest(threadId: Int) -> [ForwardMessageRequest] {
        var requests: [ForwardMessageRequest] = []
        crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.forEach { entity in
            if let codable = entity.getCodable() {
                requests.append(codable)
            }
        }
        return requests
    }
}
