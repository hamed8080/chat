//
//  AssistantActionsResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AssistantActionsResponse: ResponseModel, ResponseModelDelegates {
    
    public var actions:  [AssistantAction] = []
    
    public init(messageContent: [JSON],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        for item in messageContent {
            actions.append(AssistantAction(messageContent: item))
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(actions:        [AssistantAction],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.actions = actions
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        var actionsArray = [JSON]()
        for item in actions {
            actionsArray.append(item.formatToJSON())
        }
        let result: JSON = ["AssistantActions":     actionsArray]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
}
