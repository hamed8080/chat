//
//  GetThreadsModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetThreadsModel {
    
    // GetThreads model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var contentCount:       Int = 0
    public var hasNext:            Bool = false
    public var nextOffset:         Int = 0
    public var threads:            [Conversation] = []
    
    public var threadsJSON:        [JSON] = []
    
    public init(messageContent: [JSON],
                contentCount:  Int,
                count:         Int,
                offset:        Int,
                hasError:      Bool,
                errorMessage:  String,
                errorCode:     Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
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
            let conversationJSON = conversation.formatToJSON()
            
            threads.append(conversation)
            threadsJSON.append(conversationJSON)
        }
    }
    
    public init(conversationObjects: [Conversation],
                contentCount:  Int,
                count:         Int,
                offset:        Int,
                hasError:      Bool,
                errorMessage:  String,
                errorCode:     Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        let messageLength = conversationObjects.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in conversationObjects {
            let conversation = item
            let conversationJSON = conversation.formatToJSON()
            
            threads.append(conversation)
            threadsJSON.append(conversationJSON)
        }
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "threads":      threadsJSON]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode]
        
        return finalResult
    }
    
}








