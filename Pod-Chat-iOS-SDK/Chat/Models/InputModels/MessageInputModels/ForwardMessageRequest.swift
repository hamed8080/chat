//
//  ForwardMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class ForwardMessageRequest {
    
    public let messageIds:      [Int]
    public let threadId:        Int
    
    public let uniqueIds:       [String]
    public let typeCode: String?
    
    public init(messageIds: [Int],
                threadId:   Int,
                typeCode:   String?) {
        
        self.messageIds = messageIds
        self.threadId   = threadId
        
        var uniqueIdArr : [String] = []
        for _ in messageIds {
            let tempUniqueId = UUID().uuidString
            uniqueIdArr.append(tempUniqueId)
        }
        self.uniqueIds = uniqueIdArr
        self.typeCode   = typeCode
    }
    
    // this initializer will be deprecated later
    public init(messageIds: [Int],
                metadata:   String?,
                repliedTo:  Int?,
                threadId:   Int,
                typeCode:   String?) {
        
        self.messageIds = messageIds
        self.threadId   = threadId
        
        var uniqueIdArr : [String] = []
        for _ in messageIds {
            let tempUniqueId = UUID().uuidString
            uniqueIdArr.append(tempUniqueId)
        }
        self.uniqueIds = uniqueIdArr
        self.typeCode   = typeCode
    }
    
}

/// MARK: -  this class will be deprecate (use this class instead: 'ForwardMessageRequest')
open class ForwardMessageRequestModel: ForwardMessageRequest {
    
}
