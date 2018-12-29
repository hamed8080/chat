//
//  ReplyTextMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class ReplyTextMessageRequestModel {
    
    public let subjectId:           Int
    public let content:             String
    public let repliedTo:           Int
    public let uniqueId:            String?
    public let metaData:            JSON?
    public let typeCode:            String?
    
    public init(subjectId:         Int,
                content:           String,
                repliedTo:         Int,
                uniqueId:          String?,
                typeCode:          String?,
                metaData:          JSON?) {
        
        self.subjectId          = subjectId
        self.content            = content
        self.repliedTo          = repliedTo
        self.uniqueId           = uniqueId
        self.typeCode           = typeCode
        self.metaData           = metaData
    }
    
}

