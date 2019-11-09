//
//  AddParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddParticipantsRequestModel {
    
    public let contacts:            [Int]
    public let threadId:            Int
    public let requestTypeCode:     String?
    public let requestUniqueId:     String?
    
    public init(contacts:           [Int],
                threadId:           Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.contacts           = contacts
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

