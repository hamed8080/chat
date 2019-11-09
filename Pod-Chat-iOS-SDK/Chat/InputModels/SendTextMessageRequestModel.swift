//
//  SendTextMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class SendTextMessageRequestModel {
    
    public let content:         String
    public let metaData:        JSON?
    public let repliedTo:       Int?
    public let systemMetadata:  JSON?
    public let threadId:        Int
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(content:            String,
                metaData:           JSON?,
                repliedTo:          Int?,
                systemMetadata:     JSON?,
                threadId:           Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.systemMetadata     = systemMetadata
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}


