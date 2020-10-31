//
//  LeaveThreadRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class LeaveThreadRequest {
    
    public let threadId:        Int
    public let clearHistory:    Bool?
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(threadId:       Int,
                clearHistory:   Bool?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.threadId       = threadId
        self.clearHistory   = clearHistory
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let clearHistory_ = clearHistory {
            content["clearHistory"] = JSON(clearHistory_)
        }
        return content
    }
    
}


open class LeaveThreadRequestModel: LeaveThreadRequest {
    
}

