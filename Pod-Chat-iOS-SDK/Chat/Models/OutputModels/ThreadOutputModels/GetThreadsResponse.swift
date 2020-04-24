//
//  GetThreadsResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetThreadsModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:    Int = 0
    public var hasNext:         Bool = false
    public var nextOffset:      Int = 0
    public var threads:         [Conversation] = []
    
    public init(messageContent: [JSON],
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        let messageLength = messageContent.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in messageContent {
            let conversation = Conversation(messageContent: item)
            threads.append(conversation)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(conversationObjects:    [Conversation],
                contentCount:           Int,
                count:                  Int,
                offset:                 Int,
                hasError:               Bool,
                errorMessage:           String,
                errorCode:              Int) {
        
        let messageLength = conversationObjects.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in conversationObjects {
            threads.append(item)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        var threadArr = [JSON]()
        for item in threads {
            threadArr.append(item.formatToJSON())
        }
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "threads":      threadArr]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
    
}


open class GetThreadsResponse: GetThreadsModel {
    
}

