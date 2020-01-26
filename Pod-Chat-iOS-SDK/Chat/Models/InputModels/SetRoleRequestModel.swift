//
//  SetAdminRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class RoleRequestModel {
    
    public let userRoles:       [SetRemoveRoleModel]
//    public var roles:           [String] = []
    public let threadId:        Int
//    public let userId:          Int
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(//roles:              [Roles],
                userRoles:  [SetRemoveRoleModel],
                threadId:   Int,
//                userId:     Int,
                typeCode:   String?,
                uniqueId:   String?) {
//        for item in roles {
//            self.roles.append(item.rawValue)
//        }
//        self.userId         = userId
        
        self.userRoles  = userRoles
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = []
        for item in userRoles {
            content.appendIfArray(json: item.convertContentToJSON())
        }
        return content
    }
    
}


