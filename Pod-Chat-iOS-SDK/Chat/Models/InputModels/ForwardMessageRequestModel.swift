//
//  ForwardMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class ForwardMessageRequestModel {
    
    public let messageIds:      [Int]
    public let metadata:        String?
    public let repliedTo:       Int?
    public let threadId:        Int
    public let uniqueIds:       [String]
    
    public let typeCode: String?
    
    public init(messageIds: [Int],
                metadata:   String?,
                repliedTo:  Int?,
                threadId:   Int,
                typeCode:   String?) {
        
        self.messageIds = messageIds
        self.metadata   = metadata
        self.repliedTo  = repliedTo
        self.threadId   = threadId
        self.typeCode   = typeCode
        
        var uniqueIdArr : [String] = []
        for _ in messageIds {
            let tempUniqueId = UUID().uuidString
            uniqueIdArr.append(tempUniqueId)
        }
        self.uniqueIds = uniqueIdArr
        
    }
    
}
