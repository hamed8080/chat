//
//  QueueOfWaitTextMessagesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitTextMessagesModel {
    
    let content:        String?
//    let metadata:       JSON?
    let metadata:       String?
    let repliedTo:      Int?
//    let systemMetadata: JSON?
    let systemMetadata: String?
    let threadId:       Int?
    
    let typeCode:       String?
    let uniqueId:       String?
    
    init(content:           String?,
//         metadata:          JSON?,
         metadata:          String?,
         repliedTo:         Int?,
//         systemMetadata:    JSON?,
         systemMetadata:    String?,
         threadId:          Int?,
         typeCode:          String?,
         uniqueId:          String?) {
        
        self.content        = content
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    init(sendMessageInputModel: SendTextMessageRequestModel) {
        self.content        = sendMessageInputModel.content
//        self.metadata       = sendMessageInputModel.metadata
        self.metadata       = (sendMessageInputModel.metadata != nil) ? "\(sendMessageInputModel.metadata!)" : nil
        self.repliedTo      = sendMessageInputModel.repliedTo
//        self.systemMetadata = sendMessageInputModel.systemMetadata
        self.systemMetadata = (sendMessageInputModel.systemMetadata != nil) ? "\(sendMessageInputModel.systemMetadata!)" : nil
        self.threadId       = sendMessageInputModel.threadId
        self.typeCode       = sendMessageInputModel.typeCode
        self.uniqueId       = sendMessageInputModel.uniqueId
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["content":          content ?? NSNull(),
                            "metadata":         metadata ?? NSNull(),
                            "repliedTo":        repliedTo ?? NSNull(),
                            "systemMetadata":   systemMetadata ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return result
    }
    
}
