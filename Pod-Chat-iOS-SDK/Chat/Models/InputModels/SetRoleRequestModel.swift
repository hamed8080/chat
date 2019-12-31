//
//  SetAdminRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class RoleRequestModel {
    
    public var roles:           [String] = []
    public let threadId:        Int
    public let userId:          Int
    public let typeCode:        String?
    public let uniqueId:        String?
    
    public init(roles:              [Roles],
                threadId:           Int,
                userId:             Int,
                typeCode:           String?,
                uniqueId:           String?) {
        for item in roles {
            self.roles.append(item.rawValue)
        }
        self.threadId       = threadId
        self.userId         = userId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    
}


class SetRemoveRoleRequestModel {
    
    public let roleRequestModel:    RoleRequestModel
    public let roleOperation:       String
    
    init(roleRequestModel:  RoleRequestModel,
         roleOperation:     RoleOperations) {
        self.roleRequestModel   = roleRequestModel
        self.roleOperation      = roleOperation.returnString()
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["userId"]           = JSON(self.roleRequestModel.userId)
        content["roles"]            = JSON(self.roleRequestModel.roles)
        content["roleOperation"]    = JSON(self.roleOperation)
        content["checkThreadMembership"] = JSON(true)
        
        return content
    }
    
}


