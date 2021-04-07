//
//  DeleteMultipleMessagesRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class DeleteMultipleMessagesRequest: RequestModelDelegates {
    
    public let deleteForAll:    Bool?
    public let messageIds:      [Int]
    public let threadId:        Int
    
    public let uniqueIds:       [String]
    public let typeCode:        String?
    
    public init(deleteForAll:   Bool?,
                messageIds:     [Int],
                threadId:       Int,
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
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let deleteForAll = self.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        content["ids"] = JSON(self.messageIds)
        content["uniqueIds"] = JSON(self.uniqueIds)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

/// MARK: -  this class will be deprecate (use this class instead: 'DeleteMultipleMessagesRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class DeleteMultipleMessagesRequestModel: DeleteMultipleMessagesRequest {
    
}
