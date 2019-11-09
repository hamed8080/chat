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
    
    let messageIds:         [Int]?
    let metaData:           JSON?
    let repliedTo:          Int?
    let subjectId:          Int?
    let requestTypeCode:    String?
    let requestUniqueId:    String?
    
    init(messageIds:        [Int]?,
         metaData:          JSON?,
         repliedTo:         Int?,
         subjectId:         Int?,
         requestTypeCode:   String?,
         requestUniqueId:   String?) {
        
        self.messageIds         = messageIds
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    init(forwardMessageInputModel: ForwardMessageRequestModel, uniqueId: String) {
        self.messageIds         = forwardMessageInputModel.messageIds
        self.metaData           = forwardMessageInputModel.metaData
        self.repliedTo          = forwardMessageInputModel.repliedTo
        self.subjectId          = forwardMessageInputModel.subjectId
        self.requestTypeCode    = forwardMessageInputModel.requestTypeCode
        self.requestUniqueId    = uniqueId
    }
    
}
