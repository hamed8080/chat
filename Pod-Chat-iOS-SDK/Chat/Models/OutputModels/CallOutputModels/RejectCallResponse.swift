//
//  RejectCallResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RejectCallResponse: ResponseModel, ResponseModelDelegates {
    
    public var createCall:  CreateCallVO
    public var isRejected:  Bool
    
    public init(messageContent: JSON,
                isRejected:     Bool,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.createCall = CreateCallVO(messageContent: messageContent)
        self.isRejected = isRejected
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(createCallObject:   CreateCallVO,
                isRejected:         Bool,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.createCall = createCallObject
        self.isRejected = isRejected
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["createCallObject": createCall.formatToJSON(),
                            "isRejected":       isRejected]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        return finalResult
    }
    
}
