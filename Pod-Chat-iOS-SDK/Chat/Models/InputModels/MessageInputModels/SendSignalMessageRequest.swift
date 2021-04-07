//
//  SendSignalMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class SendSignalMessageRequest: RequestModelDelegates , Encodable {
    
    public let signalType:  SignalMessageType
    public let threadId:    Int
    public let uniqueId:    String
    
    public init(signalType: SignalMessageType,threadId:Int,uniqueId:String? = nil) {
        self.signalType = signalType
        self.threadId   = threadId
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["type"] = JSON("\(self.signalType.intValue())")
        
        return content
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
    private enum CodingKeys:String,CodingKey{
        case type = "type"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(signalType.rawValue)", forKey: .type)
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class SendSignalMessageRequestModel: SendSignalMessageRequest {
    
}
