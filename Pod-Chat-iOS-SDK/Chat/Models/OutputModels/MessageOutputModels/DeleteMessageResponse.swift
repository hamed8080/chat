//
//  DeleteMessageResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/7/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class DeleteMessageResponse: ResponseModel, ResponseModelDelegates {
    
    public let deletedMessageId: Int
    
    public init(deletedMessageId:   Int,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.deletedMessageId = deletedMessageId
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["deletedMessageId":     deletedMessageId]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}


open class DeleteMessageModel: DeleteMessageResponse {
    
}
