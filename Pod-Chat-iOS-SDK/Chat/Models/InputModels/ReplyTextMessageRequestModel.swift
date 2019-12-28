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
    
    public let content:     String
    public let metadata:    JSON?
    public let repliedTo:   Int
    public let subjectId:   Int
    
    public let typeCode:    String?
    public let uniqueId:    String?
    
    public init(content:    String,
                metadata:   JSON?,
                repliedTo:  Int,
                subjectId:  Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.content    = content
        self.metadata   = metadata
        self.repliedTo  = repliedTo
        self.subjectId  = subjectId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId
    }
    
}

