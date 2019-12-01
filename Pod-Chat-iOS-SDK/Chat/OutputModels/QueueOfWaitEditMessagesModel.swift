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
    
    let content:    String?
    let metaData:   JSON?
    let repliedTo:  Int?
    let subjectId:  Int?
    
    let typeCode:   String?
    let uniqueId:   String?
    
    init(content:   String?,
         metaData:  JSON?,
         repliedTo: Int?,
         subjectId: Int?,
         typeCode:  String?,
         uniqueId:  String?) {
        
        self.content    = content
        self.metaData   = metaData
        self.repliedTo  = repliedTo
        self.subjectId  = subjectId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId
    }
    
    init(editMessageInputModel: EditTextMessageRequestModel) {
        self.content    = editMessageInputModel.content
        self.metaData   = editMessageInputModel.metaData
        self.repliedTo  = editMessageInputModel.repliedTo
        self.subjectId  = editMessageInputModel.subjectId
        self.typeCode   = editMessageInputModel.typeCode
        self.uniqueId   = editMessageInputModel.uniqueId
    }
    
}
