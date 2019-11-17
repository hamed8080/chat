//
//  ClearHistoryRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class ClearHistoryRequestModel {
    
    public let threadId:        Int
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(threadId:           Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let requestUniqueId = self.requestUniqueId {
            content["uniqueId"] = JSON(requestUniqueId)
        }
        
        return content
    }
    
}
