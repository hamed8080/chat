//
// CMForwardInfo+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/26/22

import Foundation

public extension CMForwardInfo {
    static let crud = CoreDataCrud<CMForwardInfo>(entityName: "CMForwardInfo")

    func getCodable() -> ForwardInfo {
        ForwardInfo(conversation: conversation?.getCodable(),
                    participant: participant?.getCodable())
    }

    class func convertForwardInfoToCM(forwardInfo: ForwardInfo, messageId: Int?, threadId: Int?, entity: CMForwardInfo? = nil) -> CMForwardInfo {
        let model = entity ?? CMForwardInfo()
        model.messageId = messageId as NSNumber?
        if let participant = forwardInfo.participant {
            CMParticipant.insertOrUpdate(participant: participant, threadId: threadId) { resultEntity in
                model.participant = resultEntity
            }
        }

        if let conversation = forwardInfo.conversation {
            if let threadId = conversation.id, let threadEnitity = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
                model.conversation = threadEnitity
            } else {
                CMConversation.insertOrUpdate(conversations: [conversation]) { resultEntity in
                    model.conversation = resultEntity
                }
            }
        }
        return model
    }

    class func insertOrUpdate(forwardInfo: ForwardInfo, messageId: Int?, threadId: Int?, resultEntity: ((CMForwardInfo) -> Void)? = nil) {
        if let messageId = messageId, let findedEntity = CMForwardInfo.crud.find(keyWithFromat: "messageId == %i", value: messageId) {
            let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo, messageId: messageId, threadId: threadId, entity: findedEntity)
            resultEntity?(cmForwardInfo)
        } else {
            CMForwardInfo.crud.insert { cmForwardInfoEntity in
                let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo, messageId: messageId, threadId: threadId, entity: cmForwardInfoEntity)
                resultEntity?(cmForwardInfo)
            }
        }
    }
}
