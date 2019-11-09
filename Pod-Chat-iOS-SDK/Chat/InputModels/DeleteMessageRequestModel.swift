//
//  DeleteMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class DeleteMessageRequestModel {
    
    public let deleteForAll:    Bool?
    public let subjectId:       Int
//    public let messageId:           Int
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(deleteForAll:       Bool?,
                subjectId:          Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.deleteForAll       = deleteForAll
        self.subjectId          = subjectId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}
