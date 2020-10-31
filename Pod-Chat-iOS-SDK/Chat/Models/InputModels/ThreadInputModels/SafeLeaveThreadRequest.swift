//
//  SafeLeaveThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 8/11/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SafeLeaveThreadRequest {
    
    public let threadId:        Int
    public let clearHistory:    Bool?
    public let participantId:   Int
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(threadId:       Int,
                clearHistory:   Bool?,
                participantId:  Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.threadId       = threadId
        self.clearHistory   = clearHistory
        self.participantId  = participantId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertToLeaveThreadRequest() -> LeaveThreadRequest {
        let leaveThreadInput = LeaveThreadRequest(threadId:     self.threadId,
                                                  clearHistory: self.clearHistory,
                                                  typeCode:     self.typeCode,
                                                  uniqueId:     self.uniqueId)
        return leaveThreadInput
    }
    
}
