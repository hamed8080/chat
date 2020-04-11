//
//  ReplyTextMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class ReplyTextMessageRequestModel {
    
    public let content:     String
    public let messageType: MESSAGE_TYPE
    public let metadata:    String?
    public let repliedTo:   Int
    public let subjectId:   Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(content:        String,
                messageType:    MESSAGE_TYPE,
                metadata:       String?,
                repliedTo:      Int,
                subjectId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.content        = content
        self.messageType    = messageType
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.subjectId      = subjectId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}

