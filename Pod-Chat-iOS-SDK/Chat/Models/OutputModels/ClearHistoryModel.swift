//
//  ClearHistoryModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClearHistoryModel {
    
    // AddParticipant model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var threadId:           Int
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.threadId = messageContent["threadId"].intValue
    }
    
    public init(threadId:       Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.threadId = threadId
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["threadId":     threadId]
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
}
