//
// CMUserRole+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension CMUserRole {
    static let crud = CoreDataCrud<CMUserRole>(entityName: "CMUserRole")

    func getCodable() -> UserRole {
        UserRole(userId: id as? Int ?? 0, name: name ?? "", roles: roles as? [String])
    }

    class func convertToCM(userRole: UserRole, entity: CMUserRole? = nil) -> CMUserRole {
        let model = entity ?? CMUserRole()
        model.name = userRole.name
        model.id = userRole.userId as NSNumber?
        model.roles = userRole.roles as NSObject?

        return model
    }

    class func insertOrUpdate(userRole: UserRole, resultEntity: ((CMUserRole) -> Void)? = nil) {
        if let findedEntity = CMUserRole.crud.find(keyWithFromat: "id == %i", value: userRole.userId) {
            let cmUserRole = convertToCM(userRole: userRole, entity: findedEntity)
            resultEntity?(cmUserRole)
        } else {
            CMUserRole.crud.insert { cmUserRoleEntity in
                let cmUserRole = convertToCM(userRole: userRole, entity: cmUserRoleEntity)
                resultEntity?(cmUserRole)
            }
        }
    }
}
