//
//  UnblockContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class UnblockContactsRequestModel {
    
    public let blockId:     Int?
    public let contactId:   Int?
    public let threadId:    Int?
    public let userId:      Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(blockId:    Int?,
                contactId:  Int?,
                threadId:   Int?,
                userId:     Int?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.blockId    = blockId
        self.contactId  = contactId
        self.threadId   = threadId
        self.userId     = userId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let contactId = self.contactId {
            content["contactId"] = JSON(contactId)
        }
        if let threadId = self.threadId {
            content["threadId"] = JSON(threadId)
        }
        if let userId = self.userId {
            content["userId"] = JSON(userId)
        }
        
        return content
    }
    
}

