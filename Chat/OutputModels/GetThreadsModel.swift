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
     *          - admin:                          Bool?
     *          - canEditInfo:                    Bool?
     *          - canSpam:                        Bool?
     *          - description:                    String?
     *          - group:                          Bool?
     *          - id:                             Int?
     *          - image:                          String?
     *          - joinDate:                       Int?
     *          - lastMessage:                    String?
     *          - lastParticipantImage:           String?
     *          - lastParticipantName:            String?
     *          - lastSeenMessageId:              Int?
     *          - metadata:                       String?
     *          - mute:                           Bool?
     *          - participantCount:               Int?
     *          - partner:                        Int?
     *          - partnerLastDeliveredMessageId:  Int?
     *          - partnerLastSeenMessageId:       Int?
     *          - title:                          String?
     *          - time:                           Int?
     *          - type:                           Int?
     *          - unreadCount:                    Int?
     *          + inviter:                        Participant?
     *          + lastMessageVO:                  Message?
     *          + participants:                   [Participant]?
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








