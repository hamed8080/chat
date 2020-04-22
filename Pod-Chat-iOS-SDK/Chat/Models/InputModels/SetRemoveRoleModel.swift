//
//  SetRemoveRoleModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SetRemoveRoleModel: RequestModelDelegates {
    
    public let userId:      Int
    public var roles:       [String] = []
    
    public init(userId:     Int,
                roles:      [Roles]) {
        
        self.userId     = userId
        for item in roles {
            self.roles.append(item.stringValue())
        }
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["userId"]           = JSON(self.userId)
        content["roles"]            = JSON(self.roles)
        content["checkThreadMembership"] = JSON(false)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


