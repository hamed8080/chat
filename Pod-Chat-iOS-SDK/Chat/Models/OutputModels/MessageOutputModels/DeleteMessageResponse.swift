//
//  DeleteMessageResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/7/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class DeleteMessageModel: ResponseModel, ResponseModelDelegates {
    
    public let messageId:   Int
    public let messageType: Int
    public let edited:      Bool
    public let editable:    Bool
    public let deletable:   Bool
    public let mentioned:   Bool
    public let pinned:      Bool
    
    
    public init(messageId:      Int,
                messageType:    Int,
                edited:         Bool,
                editable:       Bool,
                deletable:      Bool,
                mentioned:      Bool,
                pinned:         Bool,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.messageId      = messageId
        self.messageType    = messageType
        self.edited         = edited
        self.editable       = editable
        self.deletable      = deletable
        self.mentioned      = mentioned
        self.pinned         = pinned
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.messageId      = messageContent["id"].intValue
        self.messageType    = messageContent["messageType"].intValue
        self.edited         = messageContent["edited"].boolValue
        self.editable       = messageContent["editable"].boolValue
        self.deletable      = messageContent["deletable"].boolValue
        self.mentioned      = messageContent["mentioned"].boolValue
        self.pinned         = messageContent["pinned"].boolValue
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["messageId":    messageId,
                            "messageType":  messageType,
                            "edited":       edited,
                            "editable":     editable,
                            "deletable":    deletable,
                            "mentioned":    mentioned,
                            "pinned":       pinned]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}


open class DeleteMessageResponse: DeleteMessageModel {
    
}


