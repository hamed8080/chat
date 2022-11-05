//
// CMCurrentUserRoles+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension CMCurrentUserRoles {
    static let crud = CoreDataCrud<CMCurrentUserRoles>(entityName: "CMCurrentUserRoles")

    func getCodable() -> [Roles] {
        roles?.roles.compactMap { Roles(rawValue: $0) } ?? []
    }

    class func convertRoleToCM(roles: [Roles], threadId: Int, entity: CMCurrentUserRoles? = nil) -> CMCurrentUserRoles {
        let model = entity ?? CMCurrentUserRoles()
        model.roles = RolesArray(roles: roles)
        model.threadId = NSNumber(value: threadId)
        return model
    }

    class func insertOrUpdate(roles: [Roles], threadId: Int, resultEntity: ((CMCurrentUserRoles) -> Void)? = nil) {
        if let findedEntity = CMCurrentUserRoles.crud.find(keyWithFromat: "threadId == %i", value: threadId) {
            let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: findedEntity)
            resultEntity?(cmUserRoles)
        } else {
            CMCurrentUserRoles.crud.insert { cmRolesEntity in
                let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: cmRolesEntity)
                resultEntity?(cmUserRoles)
            }
        }
    }
}
