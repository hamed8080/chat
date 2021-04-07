//
//  ClearHistoryRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class ClearHistoryRequest: RequestModelDelegates {
    
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.threadId   = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["threadId"] = JSON(self.threadId)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'ClearHistoryRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class ClearHistoryRequestModel: ClearHistoryRequest {
    
}
