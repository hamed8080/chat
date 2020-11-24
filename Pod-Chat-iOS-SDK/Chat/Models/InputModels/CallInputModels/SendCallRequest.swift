//
//  SendCallRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SendCallRequest {
    
    public let invitee:     Invitee?
    public let callType:    CALL_TYPE
    public let threadId:    Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    // start call with invitee Model
    public init(invitee:    Invitee,
                callType:   CALL_TYPE,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.invitee    = invitee
        self.callType   = callType
        self.threadId   = nil
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    // start call with thread Model
    public init(threadId:   Int,
                callType:   CALL_TYPE,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.invitee    = nil
        self.threadId   = threadId
        self.callType   = callType
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let invitee_ = self.invitee {
            content["invitee"] = JSON(invitee_.formatToJSON())
        }
        if let threadId_ = self.threadId {
            content["threadId"] = JSON(threadId_)
        }
        content["callType"]   = JSON(callType.intValue())
        
        if let typeCode_ = self.typeCode {
            content["typeCode"] = JSON(typeCode_)
        }
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
}
