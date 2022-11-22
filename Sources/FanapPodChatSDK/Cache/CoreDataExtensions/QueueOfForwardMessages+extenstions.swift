//
// QueueOfForwardMessages+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension QueueOfForwardMessages {
    static let crud = CoreDataCrud<QueueOfForwardMessages>(entityName: "QueueOfForwardMessages")

    func getCodable() -> ForwardMessageRequest? {
        guard let threadId = threadId as? Int,
              let fromThreadId = fromThreadId as? Int,
              let messageIdsData = messageIds?.data(using: .utf8),
              let uniqueIdsData = uniqueIds?.data(using: .utf8)
        else { return nil }
        let messageIds = try? JSONDecoder().decode([Int].self, from: messageIdsData)
        let uniqueIds = try? JSONDecoder().decode([String].self, from: uniqueIdsData)
        return ForwardMessageRequest(
            fromThreadId: fromThreadId,
            threadId: threadId,
            messageIds: messageIds ?? [],
            uniqueIds: uniqueIds ?? []
        )
    }

    class func convertToCM(request: ForwardMessageRequest, messageIds: [Int], entity: QueueOfForwardMessages? = nil) -> QueueOfForwardMessages {
        let model = entity ?? QueueOfForwardMessages()
        model.threadId = request.threadId as NSNumber?
        model.messageIds = "\(messageIds)"
        model.repliedTo = nil
        model.typeCode = Chat.sharedInstance.config?.typeCode
        model.uniqueIds = request.uniqueId
        model.fromThreadId = request.fromThreadId as NSNumber?
        return model
    }

    class func insert(request: ForwardMessageRequest, resultEntity: ((QueueOfForwardMessages) -> Void)? = nil) {
        if let entity = QueueOfForwardMessages.crud.find(keyWithFromat: "uniqueIds == %@", value: request.uniqueId) {
            resultEntity?(entity)
        } else {
            QueueOfForwardMessages.crud.insert { cmEntity in
                let cmEntity = convertToCM(request: request, messageIds: request.messageIds, entity: cmEntity)
                resultEntity?(cmEntity)
            }
        }
    }
}
