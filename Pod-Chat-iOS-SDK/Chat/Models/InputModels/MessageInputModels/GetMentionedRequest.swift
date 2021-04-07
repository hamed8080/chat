//
//  GetMentionedRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class GetMentionedRequest: RequestModelDelegates {
    
    public let count:               Int?        // Count of threads to be received
    public let offset:              Int?        // Offset of select query
    public let threadId:            Int         // Id of thread to get its history
    public let onlyUnreadMention:   Bool
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(count:              Int?,
                offset:             Int?,
                threadId:           Int,
                onlyUnreadMention:  Bool,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.count              = count
        self.offset             = offset
        self.threadId           = threadId
        self.onlyUnreadMention  = onlyUnreadMention
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    public init(json: JSON) {
        self.count              = json["count"].int
        self.offset             = json["offset"].int
        self.threadId           = json["threadId"].intValue
        self.onlyUnreadMention  = json["unreadMentioned"].boolValue
        
        self.typeCode           = json["typeCode"].string
        self.uniqueId           = json["uniqueId"].string ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"] = JSON(self.count ?? 50)
        content["offset"] = JSON(self.offset ?? 0)
        
        if onlyUnreadMention {
            content["unreadMentioned"] = JSON(true)
        } else {
            content["allMentioned"] = JSON(true)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class GetMentionRequestModel: GetMentionedRequest {
    
}
