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
    
    public let typeCode: String?
    public let uniqueId: String?
    
    public init(content:        String,
                metaData:       JSON?,
                repliedTo:      Int?,
                systemMetadata: JSON?,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.content        = content
        self.metaData       = metaData
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
}


open class SendBotMessageRequestModel {
    
    public let content:         String
    public let metaData:        JSON
    public let repliedTo:       Int?
    public let systemMetadata:  JSON?
    public let receiver:        Int
    
    public let typeCode:        String?
    public let uniqueId:        String?
    
    public init(content:        String,
                metaData:       JSON,
                repliedTo:      Int?,
                systemMetadata: JSON?,
                receiver:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.content        = content
        self.metaData       = metaData
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.receiver       = receiver
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
}


