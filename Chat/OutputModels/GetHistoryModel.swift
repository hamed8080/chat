//
//  GetHistoryModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetHistoryModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + result            [JSON]:
     *      - contentCount      Int
     *      - hasNext           Bool
     *      - nextOffset        Int
     *      + history           HistoryAsJSON
     *          - delivered:      Bool?
     *          - editable:       Bool?
     *          - edited:         Bool?
     *          - id:             Int?
     *          - message:        String?
     *          - metaData:       String?
     *          - ownerId:        Int?
     *          - previousId:     Int?
     *          - seen:           Bool?
     *          - threadId:       Int?
     *          - time:           Int?
     *          - uniqueId:       String?
     
     *          + conversation:   Conversation?
     *          + forwardInfo:    ForwardInfo?
     *          + participant:    Participant?
     *          + replyInfo:      ReplyInfo?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + history       [Message]
     ---------------------------------------
     */
    
    
    // GetHistory model properties
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    
    // result model
    var contentCount:       Int = 0
    var hasNext:            Bool = false
    var nextOffset:         Int = 0
    var history:            [Message] = []
    
    var historyJSON:        [JSON] = []
    
    init(messageContent: [JSON], contentCount: Int, count: Int, offset: Int, hasError: Bool, errorMessage: String, errorCode: Int) {
        
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
            let message = Message(threadId: nil, pushMessageVO: item)
            let messageJSON = message.formatToJSON()
            
            history.append(message)
            historyJSON.append(messageJSON)
        }
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "history":      historyJSON]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode]
        
        return finalResult
    }
}



