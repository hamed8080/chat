//
//  ClearHistoryRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class ClearHistoryRequestModel {
    
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String?
    
    public init(threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let uniqueId = self.uniqueId {
            content["uniqueId"] = JSON(uniqueId)
        }
        
        return content
    }
    
}
