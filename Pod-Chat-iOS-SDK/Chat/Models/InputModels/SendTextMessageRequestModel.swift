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
    public let metadata:        JSON?
    public let repliedTo:       Int?
    public let systemMetadata:  JSON?
    public let threadId:        Int
    
    public let typeCode: String?
    public let uniqueId: String
    
    public init(content:        String,
                metadata:       JSON?,
                repliedTo:      Int?,
                systemMetadata: JSON?,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.content        = content
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}


