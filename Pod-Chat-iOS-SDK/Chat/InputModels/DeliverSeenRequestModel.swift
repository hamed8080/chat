//
//  DeliverSeenRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class DeliverSeenRequestModel {
    
    public let messageId:       Int?
    public let ownerId:         Int
    public let requestTypeCode: String?
    
    public init(messageId:          Int?,
                ownerId:            Int,
                requestTypeCode:    String?) {
        
        self.messageId          = messageId
        self.ownerId            = ownerId
        self.requestTypeCode    = requestTypeCode
    }
    
}
