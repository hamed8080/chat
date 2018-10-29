//
//  GetThreadParticipantsModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetThreadParticipantsModel {
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
     *      + participants      ParticipantsAsJSON
     *          - cellphoneNumber:    String?
     *          - contactId:          Int?
     *          - email:              String?
     *          - firstName:          String?
     *          - id:                 Int?
     *          - image:              String?
     *          - lastName:           String?
     *          - myFriend:           Bool?
     *          - name:               String?
     *          - notSeenDuration:    Int?
     *          - online:             Bool?
     *          - receiveEnable:      Bool?
     *          - sendEnable:         Bool?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + participants  [Participants]
     ---------------------------------------
     */
    
    
    // GetThreadParticipants model properties
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    
    // result model
    var contentCount:       Int = 0
    var hasNext:            Bool = false
    var nextOffset:         Int = 0
    var participants:       [Participant] = []
    
    var participantsJSON:   [JSON] = []
    
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
            let participant = Participant(messageContent: item)
            let participantJSON = participant.formatToJSON()
            
            participants.append(participant)
            participantsJSON.append(participantJSON)
        }
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "participants": participantsJSON]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode]
        
        return finalResult
    }
}
