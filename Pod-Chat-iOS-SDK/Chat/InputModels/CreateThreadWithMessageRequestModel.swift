//
//  CreateThreadWithMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CreateThreadWithMessageRequestModel {

    public let threadDescription:       String?
    public let threadImage:             String?
    public let threadInvitees:          [Invitee]
    public let threadMetadata:          String?
    public let threadTitle:             String
    public let threadType:              ThreadTypes
    
    public let messageForwardedMessageIds:  String?
    public let messageForwardedUniqueIds:   String?
    public let messageMetaData:             String?
    public let messageRepliedTo:            Int?
    public let messageSystemMetaData:       String?
    public let messageText:                 String
    public let messageType:                 String?

    public let uniqueId:                String?
    
    public init(threadDescription:      String?,
                threadImage:            String?,
                threadInvitees:         [Invitee],
                threadMetadata:         String?,
                threadTitle:            String,
                threadType:             ThreadTypes,
                messageForwardedMessageIds: String?,
                messageForwardedUniqueIds:  String?,
                messageMetaData:        String?,
                messageRepliedTo:       Int?,
                messageSystemMetaData:  String?,
                messageText:            String,
                messageType:            String?,
                uniqueId:               String?) {
        
        self.threadDescription  = threadDescription
        self.threadImage        = threadImage
        self.threadInvitees     = threadInvitees
        self.threadMetadata     = threadMetadata
        self.threadTitle        = threadTitle
        self.threadType         = threadType
        
        self.messageForwardedMessageIds = messageForwardedMessageIds
        self.messageForwardedUniqueIds  = messageForwardedUniqueIds
        self.messageMetaData            = messageMetaData
        self.messageRepliedTo           = messageRepliedTo
        self.messageSystemMetaData      = messageSystemMetaData
        self.messageText                = messageText
        self.messageType                = messageType
        
        self.uniqueId           = uniqueId
    }

}



//open class CreateThreadWithMessageRequestModel {
//
//    public let threadDescription:       String?
//    public let threadImage:             String?
//    public let threadInvitees:          [Invitee]
//    public let threadMetadata:          JSON?
//    public let threadTitle:             String
//    public let threadType:              String?
//    public let messageContentText:      String
//    public let messageForwardMessageIds: [Int]?
//    public let messageMetaData:         JSON?
//    public let messageRepliedTo:        Int?
//    public let messageSystemMetadata:   JSON?
//    public let messageType:             Int?
//    public let messageUniqueId:         String?
//
//    public init(threadDescription:      String?,
//                threadImage:            String?,
//                threadInvitees:         [Invitee],
//                threadMetadata:         JSON?,
//                threadTitle:            String,
//                threadType:             String?,
//                messageContentText:     String,
//                messageForwardMessageIds: [Int]?,
//                messageMetaData:        JSON?,
//                messageRepliedTo:       Int?,
//                messageSystemMetadata:  JSON?,
//                messageType:            Int?,
//                messageUniqueId:        String?) {
//
//
//        self.threadDescription  = threadDescription
//        self.threadImage        = threadImage
//        self.threadInvitees     = threadInvitees
//        self.threadMetadata     = threadMetadata
//        self.threadTitle        = threadTitle
//        self.threadType         = threadType
//        self.messageContentText     = messageContentText
//        self.messageForwardMessageIds = messageForwardMessageIds
//        self.messageMetaData        = messageMetaData
//        self.messageRepliedTo       = messageRepliedTo
//        self.messageSystemMetadata  = messageSystemMetadata
//        self.messageType            = messageType
//        self.messageUniqueId        = messageUniqueId
//    }
//
//}

