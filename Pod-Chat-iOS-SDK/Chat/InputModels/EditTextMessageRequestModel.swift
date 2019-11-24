//
//  EditTextMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class EditTextMessageRequestModel {
    
    public let content:             String
    public let metaData:            JSON?
    public let repliedTo:           Int?
    public let subjectId:           Int
    
    public let requestTypeCode:     String?
    public let requestUniqueId:     String?
    
    public init(content:            String,
                metaData:           JSON?,
                repliedTo:          Int?,
                subjectId:          Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.subjectId          = subjectId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}


