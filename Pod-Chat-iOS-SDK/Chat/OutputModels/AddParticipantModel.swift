//
//  AddParticipantModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/7/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AddParticipantModel {
    
    // AddParticipant model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var thread:            Conversation?
    
    public init(messageContent: JSON,
                hasError: Bool,
                errorMessage: String,
                errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.thread = Conversation(messageContent: messageContent)
    }
    
    public init(conversation:   Conversation,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.thread = conversation
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["thread":       thread?.formatToJSON() ?? NSNull()]
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
}
