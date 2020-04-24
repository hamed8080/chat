//
//  ReplyTextMessageRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class ReplyTextMessageRequest {
    
    public let textMessage: String
    public let messageType: MessageType
    public let metadata:    String?
    public let repliedTo:   Int
    public let threadId:    Int
    
    // this variables will be deprecated soon, (use 'textMessage' instead)
    public let content: String
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(messageType:    MessageType,
                metadata:       String?,
                repliedTo:      Int,
                textMessage:    String,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.messageType    = messageType
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.textMessage    = textMessage
        self.threadId       = threadId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
        
        self.content = textMessage
    }
    
    // this initializer will be deprecated soon
    public init(content:        String,
                messageType:    MessageType,
                metadata:       String?,
                repliedTo:      Int,
                subjectId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.textMessage        = content
        
        self.content = content
        
        self.messageType    = messageType
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.threadId      = subjectId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}


open class ReplyTextMessageRequestModel: ReplyTextMessageRequest {
    
}

