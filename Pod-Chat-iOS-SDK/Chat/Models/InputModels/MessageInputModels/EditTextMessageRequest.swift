//
//  EditTextMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class EditTextMessageRequest {
    
    public let messageType: MessageType
    public let repliedTo:   Int?
    public let messageId:   Int
    public let textMessage: String
    
    // this variables will be deprecated soon, (use 'textMessage' instead)
    public let content: String
    public let metadata: String?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(messageType:    MessageType,
                repliedTo:      Int?,
                messageId:      Int,
                textMessage:    String,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.messageType    = messageType
        self.repliedTo      = repliedTo
        self.messageId      = messageId
        self.textMessage    = textMessage
        
        self.content        = textMessage
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
        
        
        
        self.metadata = nil
    }
    
    // this initializer will be deprecated later
    public init(content:        String,
                messageType:    MessageType,
                metadata:       String?,
                repliedTo:      Int?,
                messageId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.messageType    = messageType
        self.repliedTo      = repliedTo
        self.messageId      = messageId
        self.textMessage    = content
        
        self.content        = content
        self.metadata = metadata
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'EditTextMessageRequest')
@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class EditTextMessageRequestModel: EditTextMessageRequest {
    
}


