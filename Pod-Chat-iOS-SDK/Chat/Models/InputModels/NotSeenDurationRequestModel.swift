//
//  NotSeenDurationRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class NotSeenDurationRequestModel {
    
    public let userIds:     [Int]
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(userIds:    [Int],
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.userIds    = userIds
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        var users: JSON = []
        for item in userIds {
            users.appendIfArray(json: JSON(item))
        }
        content["userIds"] = JSON(users)
        return content
    }
    
}

