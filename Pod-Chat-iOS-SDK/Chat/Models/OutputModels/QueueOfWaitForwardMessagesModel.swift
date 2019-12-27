//
//  QueueOfWaitForwardMessagesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitForwardMessagesModel {
    
//    let messageIds: [Int]?
    let messageId:  Int?
    let metadata:   JSON?
    let repliedTo:  Int?
    let threadId:   Int?
    
    let typeCode:   String?
    let uniqueId:   String?
    
    init(//messageIds:    [Int]?,
         messageId:     Int?,
         metadata:      JSON?,
         repliedTo:     Int?,
         threadId:      Int?,
         typeCode:      String?,
         uniqueId:      String?) {
        
//        self.messageIds = messageIds
        self.messageId  = messageId
        self.metadata   = metadata
        self.repliedTo  = repliedTo
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId
    }
    
//    init(forwardMessageInputModel: ForwardMessageRequestModel, uniqueId: String) {
//        self.messageIds = forwardMessageInputModel.messageIds
//        self.metadata   = forwardMessageInputModel.metadata
//        self.repliedTo  = forwardMessageInputModel.repliedTo
//        self.threadId   = forwardMessageInputModel.threadId
//        self.typeCode   = forwardMessageInputModel.typeCode
//        self.uniqueId   = uniqueId
//    }
    
}
