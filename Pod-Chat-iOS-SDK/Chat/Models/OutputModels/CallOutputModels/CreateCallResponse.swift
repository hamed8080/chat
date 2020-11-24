//
//  CreateCallResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CreateCallResponse: ResponseModel, ResponseModelDelegates {
    
    public var createCall:      CreateCallVO
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.createCall = CreateCallVO(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(createCallObject:   CreateCallVO,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:      Int) {
        
        self.createCall = createCallObject
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["createCallObject":      createCall.formatToJSON()]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        return finalResult
    }
    
}
