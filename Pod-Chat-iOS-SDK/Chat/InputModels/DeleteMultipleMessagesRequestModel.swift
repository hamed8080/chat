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
    public let uniqueIds:       [String]
    
    public let typeCode:        String?
    
    public init(deleteForAll:   Bool?,
                threadId:       Int,
                messageIds:     [Int],
                typeCode:       String?) {
        
        self.deleteForAll   = deleteForAll
        self.threadId       = threadId
        self.messageIds     = messageIds
        self.typeCode       = typeCode
        
        var theUniqueIds: [String] = []
        for _ in messageIds {
            let newUniqueId = UUID().uuidString
            theUniqueIds.append(newUniqueId)
        }
        self.uniqueIds      = theUniqueIds
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let deleteForAll = self.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        content["ids"] = JSON(self.messageIds)
        content["uniqueIds"] = JSON(self.uniqueIds)
        
        return content
    }
    
}
