//
//  SendInteractiveMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class SendInteractiveMessageRequest {
    
    public let textMessage:     String
    public let messageId:       Int
    public let metadata:        String
    public let systemMetadata:  String?
    
    // this variables will be deprecated soon, (use 'textMessage' instead)
    public let content: String
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(messageId:      Int,
                metadata:       String,
                systemMetadata: String?,
                textMessage:    String,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.textMessage    = textMessage
        self.messageId      = messageId
        self.metadata       = metadata
        self.systemMetadata = systemMetadata
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
        
        
        self.content = textMessage
    }
    
    // this initializer will be deprecat soon
    public init(content:        String,
                messageId:      Int,
                metadata:       String,
                systemMetadata: String?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.textMessage    = content
        self.content = content
        self.messageId      = messageId
        self.metadata       = metadata
        self.systemMetadata = systemMetadata
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class SendInteractiveMessageRequestModel: SendInteractiveMessageRequest {
    
}

