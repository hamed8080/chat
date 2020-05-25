//
//  QueueOfWaitTextMessagesResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitTextMessagesModel {
    
    let textMessage:    String?
    let messageType:    MessageType
    let metadata:       String?
    let repliedTo:      Int?
    let systemMetadata: String?
    let threadId:       Int?
    
    let typeCode:       String?
    let uniqueId:       String?
    
    init(textMessage:       String?,
         messageType:       MessageType,
         metadata:          String?,
         repliedTo:         Int?,
         systemMetadata:    String?,
         threadId:          Int?,
         typeCode:          String?,
         uniqueId:          String?) {
        
        self.textMessage    = textMessage
        self.messageType    = messageType
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    init(sendMessageInputModel: SendTextMessageRequest) {
        self.textMessage    = sendMessageInputModel.textMessage
        self.messageType    = sendMessageInputModel.messageType
        self.metadata       = (sendMessageInputModel.metadata != nil) ? "\(sendMessageInputModel.metadata!)" : nil
        self.repliedTo      = sendMessageInputModel.repliedTo
        self.systemMetadata = (sendMessageInputModel.systemMetadata != nil) ? "\(sendMessageInputModel.systemMetadata!)" : nil
        self.threadId       = sendMessageInputModel.threadId
        self.typeCode       = sendMessageInputModel.typeCode
        self.uniqueId       = sendMessageInputModel.uniqueId
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["textMessage":      textMessage ?? NSNull(),
                            "messageType":      messageType,
                            "metadata":         metadata ?? NSNull(),
                            "repliedTo":        repliedTo ?? NSNull(),
                            "systemMetadata":   systemMetadata ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return result
    }
    
}

open class QueueOfWaitTextMessagesResponse: QueueOfWaitTextMessagesModel {
    
}

