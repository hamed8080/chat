//
//  SendSignalMessageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/12/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class SendSignalMessageRequestModel {
    
    public let signalType:      SignalMessageType
    public let threadId:        Int
    public let requestUniqueId: String?
    
    public init(signalType:         SignalMessageType,
                threadId:           Int,
                requestUniqueId:    String?) {
        
        self.signalType         = signalType
        self.threadId           = threadId
        self.requestUniqueId    = requestUniqueId
    }
    
}
