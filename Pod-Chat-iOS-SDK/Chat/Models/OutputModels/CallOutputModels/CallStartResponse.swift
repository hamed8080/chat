//
//  CallStartResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CallStartResponse: ResponseModel, ResponseModelDelegates {
    
    public var callName:    String?
    public var callImage:   String?
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.callName   = messageContent["callName"].string
        self.callImage  = messageContent["callImage"].string
        
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(callName:       String,
                callImage:      String,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.callName   = callName
        self.callImage  = callImage
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["callName":     callName ?? NSNull(),
                            "callImage":    callImage ?? NSNull()]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        return finalResult
    }
    
}
