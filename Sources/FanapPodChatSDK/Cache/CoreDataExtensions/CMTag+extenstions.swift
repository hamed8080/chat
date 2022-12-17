//
// CMTag+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension CMTag {
    static let crud = CoreDataCrud<CMTag>(entityName: "CMTag")

    func getCodable() -> Tag? {
        Tag(id: id as? Int ?? 0,
            name: name,
            owner: owner.getCodable(),
            active: Bool(exactly: active) ?? false,
            tagParticipants: tagParticipants?.compactMap { $0.getCodable() } ?? [])
    }

    class func convertToCM(tag: Tag, entity: CMTag? = nil) -> CMTag {
        let model = entity ?? CMTag()

        model.id = tag.id as NSNumber?
        model.name = tag.name
        model.active = tag.active as NSNumber

        if let tagParticipants = tag.tagParticipants {
            tagParticipants.forEach { tagParticipant in
                CMTagParticipant.insertOrUpdate(tagParticipant: tagParticipant, tagId: tag.id) { resultEntity in
                    model.tagParticipants?.insert(resultEntity)
                }
            }
        }

        CMParticipant.insertOrUpdate(participant: tag.owner) { resultEntity in
            model.owner = resultEntity
        }

        return model
    }

    class func insertOrUpdate(tags: [Tag], resultEntity: ((CMTag) -> Void)? = nil) {
        tags.forEach { tag in
            if let findedEntity = CMTag.crud.find(keyWithFromat: "id == %i", value: tag.id) {
                let cmTag = convertToCM(tag: tag, entity: findedEntity)
                resultEntity?(cmTag)
            } else {
                CMTag.crud.insert { cmTagEntity in
                    let cmTag = convertToCM(tag: tag, entity: cmTagEntity)
                    resultEntity?(cmTag)
                }
            }
        }
    }

    class func addParticipant(tagId: Int, tagParticipant: CMTagParticipant) {
        if let tag = CMTag.crud.find(keyWithFromat: "id == %i", value: tagId) {
            tag.tagParticipants?.insert(tagParticipant)
        }
    }
}
