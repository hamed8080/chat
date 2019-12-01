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
    
    public let messageIds:      [Int]
    public let metaData:        JSON?
    public let repliedTo:       Int?
    public let subjectId:       Int
    
    public let typeCode: String?
    
    public init(messageIds: [Int],
                metaData:   JSON?,
                repliedTo:  Int?,
                subjectId:  Int,
                typeCode:   String?) {
        
        self.messageIds = messageIds
        self.metaData   = metaData
        self.repliedTo  = repliedTo
        self.subjectId  = subjectId
        self.typeCode   = typeCode
    }
    
}
