//
//  ForwardMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ForwardMessageRequestModel {
    
    public let subjectId:           Int
    public let messageIds:          [Int]
    public let repliedTo:           Int?
    public let metaData:            JSON?
    public let typeCode:            String?
    
    init(subjectId:         Int,
         messageIds:        [Int],
         repliedTo:         Int?,
         typeCode:          String?,
         metaData:          JSON?) {
        
        self.subjectId          = subjectId
        self.messageIds         = messageIds
        self.repliedTo          = repliedTo
        self.typeCode           = typeCode
        self.metaData           = metaData
    }
    
}

