//
//  CallInfo.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CallInfo {
    
    public var partnerId:   Int?
    public var callName:    String?
    public var callImage:   String?
    public var callId:      Int?
    
    public init(messageContent: JSON) {
        self.partnerId  = messageContent["partnerId"].int
        self.callName   = messageContent["callName"].string
        self.callImage  = messageContent["callImage"].string
        self.callId     = messageContent["callId"].int
    }
    
    public init(partnerId:  Int,
                callName:   String,
                callImage:  String,
                callId:     Int) {
        self.partnerId  = partnerId
        self.callName   = callName
        self.callImage  = callImage
        self.callId     = callId
    }
    
    public init(theCallInfo: CallInfo) {
        self.partnerId  = theCallInfo.partnerId
        self.callName   = theCallInfo.callName
        self.callImage  = theCallInfo.callImage
        self.callId     = theCallInfo.callId
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["partnerId":    partnerId ?? NSNull(),
                            "callName":     callName ?? NSNull(),
                            "callImage":    callImage ?? NSNull(),
                            "callId":       callId ?? NSNull()]
        return result
    }
    
}
