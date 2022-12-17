//
// CMLinkedUser+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension CMLinkedUser {
    static let crud = CoreDataCrud<CMLinkedUser>(entityName: "CMLinkedUser")

    func getCodable() -> LinkedUser {
        LinkedUser(coreUserId: coreUserId as? Int,
                   image: image,
                   name: name,
                   nickname: nickname,
                   username: username)
    }

    class func convertLinkUserToCM(linkedUser: LinkedUser, entity: CMLinkedUser? = nil) -> CMLinkedUser {
        let model = entity ?? CMLinkedUser()
        model.coreUserId = linkedUser.coreUserId as NSNumber?
        model.image = linkedUser.image
        model.name = linkedUser.name
        model.nickname = linkedUser.nickname
        model.username = linkedUser.username

        return model
    }

    class func insertOrUpdate(linkedUser: LinkedUser, resultEntity: ((CMLinkedUser) -> Void)? = nil) {
        if let coreUserId = linkedUser.coreUserId, let findedEntity = CMLinkedUser.crud.find(keyWithFromat: "coreUserId == %i", value: coreUserId) {
            let cmLinkedUser = convertLinkUserToCM(linkedUser: linkedUser, entity: findedEntity)
            resultEntity?(cmLinkedUser)
        } else {
            CMLinkedUser.crud.insert { cmLinkedUserEntity in
                let cmLinkedUser = convertLinkUserToCM(linkedUser: linkedUser, entity: cmLinkedUserEntity)
                resultEntity?(cmLinkedUser)
            }
        }
    }
}
