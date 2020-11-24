//
//  RejectCallRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RejectCallRequest {
    
    public let callId:      Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(callId:     Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.callId     = callId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        
        content["callId"]   = JSON(callId)
        
        if let typeCode_ = self.typeCode {
            content["typeCode"] = JSON(typeCode_)
        }
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
}
