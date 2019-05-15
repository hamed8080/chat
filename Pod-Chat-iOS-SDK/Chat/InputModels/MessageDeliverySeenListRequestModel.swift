//
//  MessageDeliverySeenListRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MessageDeliverySeenListRequestModel {
    
    public let count:       Int?
    public let messageId:   Int
    public let offset:      Int?
    public let typeCode:    String?
    
    public init(count:     Int?,
                messageId: Int,
                offset:    Int?,
                typeCode:  String?) {
        
        self.count      = count
        self.messageId  = messageId
        self.offset     = offset
        self.typeCode   = typeCode
    }
    
}
