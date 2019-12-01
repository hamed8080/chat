//
//  DeleteMultipleMessagesRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DeleteMultipleMessagesRequestModel {
    
    public let deleteForAll:    Bool?
    public let threadId:        Int
    public let messageIds:      [Int]
    
    public let typeCode:        String?
    public let uniqueIds:       [String]?
    
    public init(deleteForAll:   Bool?,
                threadId:       Int,
                messageIds:     [Int],
                typeCode:       String?,
                uniqueIds:      [String]?) {
        
        self.deleteForAll   = deleteForAll
        self.threadId       = threadId
        self.messageIds     = messageIds
        self.typeCode       = typeCode
        self.uniqueIds      = uniqueIds
    }
    
}
