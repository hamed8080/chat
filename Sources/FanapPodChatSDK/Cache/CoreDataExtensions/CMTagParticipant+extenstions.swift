//
// CMTagParticipant+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension CMTagParticipant {
    static let crud = CoreDataCrud<CMTagParticipant>(entityName: "CMTagParticipant")

    func getCodable() -> TagParticipant? {
        TagParticipant(id: id as? Int,
                       active: active as? Bool,
                       tagId: tagId as? Int,
                       threadId: threadId as? Int,
                       conversation: conversation?.getCodable())
    }

    class func convertToCM(tagParticipant: TagParticipant, tagId: Int, entity: CMTagParticipant? = nil) -> CMTagParticipant {
        let model = entity ?? CMTagParticipant()
        model.id = tagParticipant.id as NSNumber?
        model.active = tagParticipant.active as NSNumber?
        model.tagId = tagParticipant.tagId as NSNumber? ?? tagId as NSNumber?
        model.threadId = tagParticipant.threadId as NSNumber?

        if let conversation = tagParticipant.conversation {
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

    class func insertOrUpdate(tagParticipant: TagParticipant, tagId: Int, resultEntity: ((CMTagParticipant) -> Void)? = nil) {
        if let id = tagParticipant.id, let findedEntity = CMTagParticipant.crud.find(keyWithFromat: "id == %i", value: id) {
            let cmTagParticipant = convertToCM(tagParticipant: tagParticipant, tagId: tagId, entity: findedEntity)
            resultEntity?(cmTagParticipant)
        } else {
            CMTagParticipant.crud.insert { cmTagParticipantEntity in
                let cmTagParticipant = convertToCM(tagParticipant: tagParticipant, tagId: tagId, entity: cmTagParticipantEntity)
                resultEntity?(cmTagParticipant)
            }
        }
    }
}
