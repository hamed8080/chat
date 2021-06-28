//
//  NotSeenDurationRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class GetNotSeenDurationRequest: RequestModelDelegates {
    
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
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        var users: JSON = []
        for item in userIds {
            users.appendIfArray(json: JSON(item))
        }
        content["userIds"] = JSON(users)
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate.  (use this class instead: 'NotSeenDurationRequest')
@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class NotSeenDurationRequestModel: GetNotSeenDurationRequest {
    
}

