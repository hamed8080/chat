//
//  AssistantResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AssistantResponse: ResponseModel, ResponseModelDelegates {
    
    public var assistants:  [AssistantVO] = []
    
    public init(messageContent: [JSON],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        for item in messageContent {
            assistants.append(AssistantVO(messageContent: item))
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(assistants:     [AssistantVO],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.assistants = assistants
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        var assistsArray = [JSON]()
        for item in assistants {
            assistsArray.append(item.formatToJSON())
        }
        let result: JSON = ["assistants":           assistsArray]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
}

