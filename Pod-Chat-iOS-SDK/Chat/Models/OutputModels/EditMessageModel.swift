//
//  EditMessageModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/7/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class EditMessageModel {
    
    // EditMessageModel model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var editedMessage:       Message?
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.editedMessage = Message(threadId: messageContent["conversation"]["id"].int, pushMessageVO: messageContent)
    }
    
    public init(message:        Message?,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["editedMessage":    editedMessage?.formatToJSON() ?? NSNull()]
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
    
}
