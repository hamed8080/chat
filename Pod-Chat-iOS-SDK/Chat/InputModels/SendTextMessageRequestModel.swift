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
    
    public let threadId:            Int
    public let content:             String
    public let repliedTo:           Int?
    public let uniqueId:            String?
    public let systemMetadata:      JSON?
    public let metaData:            JSON?
    public let typeCode:            String?
    
    public init(threadId:          Int,
                content:           String,
                repliedTo:         Int?,
                uniqueId:          String?,
                typeCode:          String?,
                systemMetadata:    JSON?,
                metaData:          JSON?) {
        
        self.threadId           = threadId
        self.content            = content
        self.repliedTo          = repliedTo
        self.uniqueId           = uniqueId
        self.typeCode           = typeCode
        self.systemMetadata     = systemMetadata
        self.metaData           = metaData
    }
    
}


