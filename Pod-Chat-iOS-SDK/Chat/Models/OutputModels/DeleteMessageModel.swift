//
//  DeleteMessageModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/7/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class DeleteMessageModel {
    
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public let deletedMessageId:       Int
    
    public init(deletedMessageId:      Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.deletedMessageId   = deletedMessageId
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
