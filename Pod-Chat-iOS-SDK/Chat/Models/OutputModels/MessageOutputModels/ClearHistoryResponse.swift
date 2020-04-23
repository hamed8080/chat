//
//  ClearHistoryResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClearHistoryResponse: ResponseModel, ResponseModelDelegates {
    
    public var threadId:           Int
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.threadId = messageContent["threadId"].intValue
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(threadId:       Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.threadId = threadId
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
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


open class ClearHistoryModel: ClearHistoryResponse {
    
}
