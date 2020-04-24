//
//  SendSignalMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SendSignalMessageRequest: RequestModelDelegates {
    
    public let signalType:  SignalMessageType
    public let threadId:    Int
    
    public let uniqueId:    String
    
    public init(signalType: SignalMessageType,
                threadId:   Int,
                uniqueId:   String?) {
        
        self.signalType = signalType
        self.threadId   = threadId
        
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["type"] = JSON("\(self.signalType.intValue())")
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


open class SendSignalMessageRequestModel: SendSignalMessageRequest {
    
}
