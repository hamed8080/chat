//
//  QueueOfWaitEditMessagesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitEditMessagesModel {
    
    let content:            String?
    let metaData:           JSON?
    let repliedTo:          Int?
    let subjectId:          Int?
    let requestTypeCode:    String?
    let requestUniqueId:    String?
    
    init(content:           String?,
         metaData:          JSON?,
         repliedTo:         Int?,
         subjectId:         Int?,
         requestTypeCode:   String?,
         requestUniqueId:   String?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    init(editMessageInputModel: EditTextMessageRequestModel) {
        self.content            = editMessageInputModel.content
        self.metaData           = editMessageInputModel.metaData
        self.repliedTo          = editMessageInputModel.repliedTo
        self.subjectId          = editMessageInputModel.subjectId
        self.requestTypeCode    = editMessageInputModel.requestTypeCode
        self.requestUniqueId    = editMessageInputModel.requestUniqueId
    }
    
}
