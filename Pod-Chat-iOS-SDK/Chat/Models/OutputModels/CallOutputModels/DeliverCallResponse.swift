//
//  DeliverCallResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DeliverCallResponse: ResponseModel, ResponseModelDelegates {
    
    public var createCall:  CreateCallVO
    public var isDelivered: Bool
    
    public init(messageContent: JSON,
                isDelivered:    Bool,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.createCall = CreateCallVO(messageContent: messageContent)
        self.isDelivered = isDelivered
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(createCallObject:   CreateCallVO,
                isDelivered:        Bool,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.createCall = createCallObject
        self.isDelivered = isDelivered
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["createCallObject": createCall.formatToJSON(),
                            "isDelivered":      isDelivered]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        return finalResult
    }
    
}
