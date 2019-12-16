//
//  SetAdminRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class SetRoleRequestModel {
    
    public var roles:           [String] = []
    public let roleOperation:   String
    public let threadId:        Int
    public let userId:          Int
    public let typeCode:        String?
    public let uniqueId:        String?
    
    public init(roles:              [Roles],
                roleOperation:      RoleOperations,
                threadId:           Int,
                userId:             Int,
                typeCode:           String?,
                uniqueId:           String?) {
        for item in roles {
            self.roles.append(item.rawValue)
        }
        self.roleOperation  = roleOperation.rawValue
        self.threadId       = threadId
        self.userId         = userId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["userId"]           = JSON(self.userId)
        content["roles"]            = JSON(self.roles)
        content["roleOperation"]    = JSON(self.roleOperation)
        content["checkThreadMembership"] = JSON(true)
        
        return content
    }
    
}


//open class RequestRole {
//
//    public let id:              Int
//    public let roleTypes:       [String]
//    public let roleOperation:   String
//
//    init(id: Int, roleTypes: [String], roleOperation: String) {
//        self.id             = id
//        self.roleTypes      = roleTypes
//        self.roleOperation  = roleOperation
//    }
//
//}

//open class UserRoleVO {
//
//    let userId:                 Int
//    let checkThreadMembership:  Bool
//    let roles:                  [String]
//    let roleOperation:          String
//
//    init(userId: Int, checkThreadMembership: Bool, roles: [String], roleOperation: String) {
//        self.userId                 = userId
//        self.checkThreadMembership  = checkThreadMembership
//        self.roles                  = roles
//        self.roleOperation          = roleOperation
//    }
//
//}
