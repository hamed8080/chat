//
//  CloseThreadResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 8/11/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CloseThreadResponse: ResponseModel, ResponseModelDelegates {
    
    public let threadId:    Int
    
    public init(threadId:       Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.threadId   = threadId
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["threadId":     threadId]

        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]

        return resultAsJSON
    }

}
