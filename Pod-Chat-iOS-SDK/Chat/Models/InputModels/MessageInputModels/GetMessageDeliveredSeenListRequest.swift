//
//  GetMessageDeliveredSeenListRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class GetMessageDeliveredSeenListRequest: RequestModelDelegates {
    
    public let count:       Int?
    public let messageId:   Int
    public let offset:      Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(count:      Int?,
                messageId:  Int,
                offset:     Int?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.count      = count
        self.messageId  = messageId
        self.offset     = offset
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"] = JSON(self.count ?? 50)
        content["offset"] = JSON(self.offset ?? 0)
        content["messageId"] = JSON(self.messageId)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class MessageDeliverySeenListRequestModel: GetMessageDeliveredSeenListRequest {
    
}
