//
//  SetRemoveRoleRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


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


