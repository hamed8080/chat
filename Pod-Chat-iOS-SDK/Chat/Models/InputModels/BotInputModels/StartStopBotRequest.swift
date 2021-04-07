//
//  StartStopBotRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class StartStopBotRequest: RequestModelDelegates {
    
    public let botName:     String
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(botName:    String,
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.botName    = botName
        self.threadId   = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["botName"] = JSON(botName)
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}
