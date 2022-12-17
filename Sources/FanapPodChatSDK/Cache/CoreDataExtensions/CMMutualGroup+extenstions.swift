//
// CMMutualGroup+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/26/22

import Foundation

public extension CMMutualGroup {
    static let crud = CoreDataCrud<CMMutualGroup>(entityName: "CMMutualGroup")

    internal class func convertMutualGroupToCM(conversation: Conversation, req: MutualGroupsRequest, entity: CMMutualGroup? = nil) -> CMMutualGroup {
        let model = entity ?? CMMutualGroup()
        model.idType = req.toBeUserVO.idType as NSNumber?
        model.mutualId = req.toBeUserVO.id
        if let threadId = conversation.id, let threadEnitity = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
            model.conversation = threadEnitity
        } else {
            CMConversation.insertOrUpdate(conversations: [conversation]) { resultEntity in
                model.conversation = resultEntity
            }
        }
        return model
    }

    class func insertOrUpdate(conversations: [Conversation], req: MutualGroupsRequest, resultEntity: ((CMMutualGroup) -> Void)? = nil) {
        conversations.forEach { conversation in
            if let findedEntity = CMMutualGroup.crud.fetchWith(NSPredicate(format: "mutualId == %@ AND idType == %i", req.toBeUserVO.id!, req.toBeUserVO.id!))?.first {
                let cmConversation = convertMutualGroupToCM(conversation: conversation, req: req, entity: findedEntity)
                resultEntity?(cmConversation)
            } else {
                CMMutualGroup.crud.insert { entity in
                    let cmConversation = convertMutualGroupToCM(conversation: conversation, req: req, entity: entity)
                    resultEntity?(cmConversation)
                }
            }
        }
    }

    class func getMutualGroups(_ req: MutualGroupsRequest) -> [Conversation] {
        guard let mutualId = req.toBeUserVO.id, let idType = req.toBeUserVO.idType else { return [] }
        let predicate = NSPredicate(format: "mutualId == %@ AND idType == %i", mutualId, idType)
        let conversationsWithMutual = CMMutualGroup.crud.fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate)
        let conversations = conversationsWithMutual.compactMap { $0.conversation?.getCodable() }
        return conversations
    }
}
