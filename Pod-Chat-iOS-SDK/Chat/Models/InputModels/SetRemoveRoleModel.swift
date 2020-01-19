//
//  SetRemoveRoleModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class SetRemoveRoleModel {
    
    public let userId:  Int
    public var roles:   [String] = []
    
    public init(userId: Int, roles: [Roles]) {
        self.userId = userId
        for item in roles {
            self.roles.append(item.rawValue)
        }
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["userId"]           = JSON(self.userId)
        content["roles"]            = JSON(self.roles)
//        content["roleOperation"]    = JSON(self.roleOperation)
        content["checkThreadMembership"] = JSON(false)
        
        return content
    }
    
}


//class SetRemoveRoleRequestModel {
//
//    public let roleRequestModel:    RoleRequestModel
//    public let roleOperation:       String
//
//    init(roleRequestModel:  RoleRequestModel,
//         roleOperation:     RoleOperations) {
//        self.roleRequestModel   = roleRequestModel
//        self.roleOperation      = roleOperation.returnString()
//    }
//
//    func convertContentToJSON() -> JSON {
//        var content: JSON = [:]
//        content["userId"]           = JSON(self.roleRequestModel.userId)
//        content["roles"]            = JSON(self.roleRequestModel.roles)
////        content["roleOperation"]    = JSON(self.roleOperation)
//        content["checkThreadMembership"] = JSON(false)
//
//        return content
//    }
//
//}


