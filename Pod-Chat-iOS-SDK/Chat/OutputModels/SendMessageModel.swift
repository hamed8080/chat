//
//  SendMessageModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/26/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class SendMessageModel {
    
    // SendMessage model properties
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    // result model
    public var isSent:          Bool
    public var isDelivered:     Bool
    public var isSeen:          Bool
    public var threadId:        Int?
    public var participantId:   Int?
    
    public let messageId:       Int
    public var message:         Message?
    
    public init(messageContent: JSON?,
                messageId:      Int,
                isSent:         Bool,
                isDelivered:    Bool,
                isSeen:         Bool,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int,
                threadId:       Int?,
                participantId:  Int?) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.isSent         = isSent
        self.isDelivered    = isDelivered
        self.isSeen         = isSeen
        
        self.messageId      = messageId
        
        if let msg = messageContent {
            self.message        = Message(threadId: nil, pushMessageVO: msg)
        }
        if let tId = threadId {
            self.threadId = tId
        }
        if let pId = participantId {
            self.participantId = pId
        }
    }
    
    public init(messageContent: Message?,
                messageId:      Int,
                isSent:         Bool,
                isDelivered:    Bool,
                isSeen:         Bool,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int,
                threadId:       Int?,
                participantId:  Int?) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.isSent         = isSent
        self.isDelivered    = isDelivered
        self.isSeen         = isSeen
        
        self.messageId      = messageId
        
        if let msg = messageContent {
            self.message        = msg
        }
        if let tId = threadId {
            self.threadId = tId
        }
        if let pId = participantId {
            self.participantId = pId
        }
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["isSent":       isSent,
                            "isDelivered":  isDelivered,
                            "isSeen":       isSeen,
                            "threadId":     threadId ?? NSNull(),
                            "messageId":    messageId,
                            "participantId": participantId ?? NSNull(),
                            "message":      message?.formatToJSON() ?? NSNull()]
        
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
}




