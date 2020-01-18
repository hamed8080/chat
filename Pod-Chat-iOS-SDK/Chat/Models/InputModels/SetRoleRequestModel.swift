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
    public let uniqueId:        String
    
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
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
}


