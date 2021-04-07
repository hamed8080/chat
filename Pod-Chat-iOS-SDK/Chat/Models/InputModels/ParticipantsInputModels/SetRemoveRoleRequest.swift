//
//  SetRemoveRoleRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class SetRemoveRoleRequest: RequestModelDelegates {
    
    public let userRoles:       [SetRemoveRoleModel]
    public let threadId:        Int
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(userRoles:  [SetRemoveRoleModel],
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.userRoles  = userRoles
        self.threadId   = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = []
        for item in userRoles {
            content.appendIfArray(json: item.convertContentToJSON())
        }
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class RoleRequestModel: SetRemoveRoleRequest {
    
}


