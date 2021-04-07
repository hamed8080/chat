//
//  GetHistoryResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetHistoryModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:    Int = 0
    public var hasNext:         Bool = false
    public var nextOffset:      Int = 0
    public var threadId:        Int?
    
    public var history:         [Message] = []
    
    public init(messageContent: [JSON],
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int,
                threadId:       Int?) {
        
        if let tId = threadId {
            self.threadId = tId
        }
        
        let messageLength = messageContent.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in messageContent {
            let message = Message(threadId: nil, pushMessageVO: item)
            history.append(message)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContent: [Message]?,
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int,
                threadId:       Int?) {
        
        if let tId = threadId {
            self.threadId = tId
        }
        
        self.contentCount = contentCount
        self.hasNext = false
        
        if let messages = messageContent {
            
            let messageLength = messages.count
            let x: Int = count + offset
            if (x < contentCount) && (messageLength > 0) {
                self.hasNext = true
            }
            self.nextOffset = offset + messageLength
            
            for item in messages {
                history.append(item)
            }
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var messageArr = [JSON]()
        for item in history {
            messageArr.append(item.formatToJSON())
        }
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "threadId":     threadId ?? NSNull(),
                            "history":      messageArr]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
}

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetHistoryResponse: GetHistoryModel {
    
}


