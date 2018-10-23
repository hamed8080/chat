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
     *      + threads           ThreadsAsJSON
     *          - id                            Int
     *          - joinDate                      Int
     *          - title                         String
     *          - time                          Int
     *          - lastMessage                   String
     *          - lastParticipantName           String
     *          - group                         Bool
     *          - partner                       Int
     *          - lastParticipantImage          String
     *          - image                         String
     *          - description                   String
     *          - unreadCount                   Int
     *          - lastSeenMessageId             Int
     *          - partnerLastSeenMessageId      Int
     *          - partnerLastDeliveredMessageId Int
     *          - type                          Int
     *          - metadata                      String
     *          - mute                          Bool
     *          - participantCount              Int
     *          - canEditInfo                   Bool
     *          - canSpam                       Bool
     *          + inviter               Invitee
     *          + participants          [Participant]
     *          + lastMessageVO         Message
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + threads       [Conversation]
     ---------------------------------------
     */
    
    // GetThreads model properties
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    
    // result model
    var contentCount:       Int = 0
    var hasNext:            Bool = false
    var nextOffset:         Int = 0
    var threads:            [Conversation] = []
    
    var threadsJSON:        [JSON] = []
    
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
            let conversation = Conversation(messageContent: item)
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

