//
//  ClearHistoryRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class ClearHistoryRequestModel {
    
    public let threadId:        Int
    public let requestUniqueId: String?
    
    public init(threadId:           Int,
                requestUniqueId:    String?) {
        
        self.threadId           = threadId
        self.requestUniqueId    = requestUniqueId
    }
    
}
