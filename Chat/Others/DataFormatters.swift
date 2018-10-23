////
////  DataFormatters.swift
////  Chat
////
////  Created by Mahyar Zhiani on 6/4/1397 AP.
////  Copyright © 1397 Mahyar Zhiani. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//
//class AddParticipantsModel {
//    /*
//     ---------------------------------------
//     * responseAsJSON:
//     *  - hasError     Bool
//     *  - errorMessage String
//     *  - errorCode    Int
//     *  + result       JSON or UserInfoModel:
//     *      + threads       ThreadsAsJSON
//     *          - id                            Int
//     *          - joinDate                      Int
//     *          - title                         String
//     *          - time                          Int
//     *          - lastMessage                   String
//     *          - lastParticipantName           String
//     *          - group                         Bool
//     *          - partner                       Int
//     *          - lastParticipantImage          String
//     *          - image                         String
//     *          - description                   String
//     *          - unreadCount                   Int
//     *          - lastSeenMessageId             Int
//     *          - partnerLastSeenMessageId      Int
//     *          - partnerLastDeliveredMessageId Int
//     *          - type                          Int
//     *          - metadata                      String
//     *          - mute                          Bool
//     *          - participantCount              Int
//     *          - canEditInfo                   Bool
//     *          - canSpam                       Bool
//     *          + inviter               Invitee
//     *          + participants          [Participant]
//     *          + lastMessageVO         Message
//     ---------------------------------------
//     * responseAsModel:
//     *  - hasError     Bool
//     *  - errorMessage String
//     *  - errorCode    Int
//     *  + user         User
//     ---------------------------------------
//     */
//
//    // GetThreads model properties
//    let hasError:           Bool
//    let errorMessage:       String
//    let errorCode:          Int
//
//    // result model
//    var contentCount:       Int = 0
//    var hasNext:            Bool = false
//    var nextOffset:         Int = 0
//    var thread:             Conversation?
//
//    var threadJSON:         JSON?
//
//    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
//        self.hasError           = hasError
//        self.errorMessage       = errorMessage
//        self.errorCode          = errorCode
//
//        self.thread = Conversation(messageContent: messageContent)
//        self.threadJSON = thread?.formatToJSON()
//
//    }
//
//    func returnDataAsJSON() -> JSON {
//        let result: JSON = ["thread": threadJSON ?? NSNull()]
//
//        let resultAsJSON: JSON = ["result": result,
//                                  "hasError": hasError,
//                                  "errorMessage": errorMessage,
//                                  "errorCode": errorCode]
//
//        return resultAsJSON
//    }
//}








