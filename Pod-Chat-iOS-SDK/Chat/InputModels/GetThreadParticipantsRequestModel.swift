//
//  GetThreadParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class GetThreadParticipantsRequestModel {
    
    public let admin:           Bool?   // if we want to only get admins, we'll send this parameter as "true"
    public let count:           Int?    // Count of objects to get
    public let firstMessageId:  Int?
    public let lastMessageId:   Int?
    public let name:            String? // Search in Participants list (LIKE in name, contactName, email)
    public let offset:          Int?    // Offset of select Query
    public let threadId:        Int     // Id of thread which you want to get participants of
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(admin:              Bool?,
                count:              Int?,
                firstMessageId:     Int?,
                lastMessageId:      Int?,
                name:               String?,
                offset:             Int?,
                threadId:           Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.admin              = admin
        self.count              = count
        self.firstMessageId     = firstMessageId
        self.lastMessageId      = lastMessageId
        self.name               = name
        self.offset             = offset
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        
        if let firstMessageId = self.firstMessageId {
            content["firstMessageId"]   = JSON(firstMessageId)
        }
        
        if let lastMessageId = self.lastMessageId {
            content["lastMessageId"]   = JSON(lastMessageId)
        }
        
        if let name = self.name {
            content["name"]   = JSON(name)
        }
        
        if let admin = self.admin {
            content["admin"]   = JSON(admin)
        }
        
        return content
    }
    
}

