//
//  ThreadResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class ThreadModel: ResponseModel, ResponseModelDelegates {
    
    public var thread: Conversation?
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.thread = Conversation(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(conversation:   Conversation?,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.thread = conversation
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
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



@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class ThreadResponse: ThreadModel {
    
}
