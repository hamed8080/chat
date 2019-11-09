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
    
    let content:            String?
    let metaData:           JSON?
    let repliedTo:          Int?
    let systemMetadata:     JSON?
    let threadId:           Int?
    let requestTypeCode:    String?
    let requestUniqueId:    String?
    
    init(content:           String?,
         metaData:          JSON?,
         repliedTo:         Int?,
         systemMetadata:    JSON?,
         threadId:          Int?,
         requestTypeCode:   String?,
         requestUniqueId:   String?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.systemMetadata     = systemMetadata
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    init(sendMessageInputModel: SendTextMessageRequestModel) {
        self.content            = sendMessageInputModel.content
        self.metaData           = sendMessageInputModel.metaData
        self.repliedTo          = sendMessageInputModel.repliedTo
        self.systemMetadata     = sendMessageInputModel.systemMetadata
        self.threadId           = sendMessageInputModel.threadId
        self.requestTypeCode    = sendMessageInputModel.requestTypeCode
        self.requestUniqueId    = sendMessageInputModel.requestUniqueId
    }
    
}
