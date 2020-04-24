//
//  PinUnpinMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class PinUnpinMessageRequest: RequestModelDelegates {
    
    public let messageId:   Int
    public let notifyAll:   Bool
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(messageId:  Int,
                notifyAll:  Bool,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.messageId  = messageId
        self.notifyAll  = notifyAll
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["notifyAll"] = JSON(notifyAll)
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}



open class PinAndUnpinMessageRequestModel: PinUnpinMessageRequest {
    
}

