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
    public let threadType:              String?
    public let uniqueId:                String?
    public let messageContent:          String
    public let messageMetaDataId:       Int?
    public let messageMetaDataType:     String?
    public let messageMetaDataOwner:    String?


    public init(threadDescription:      String?,
                threadImage:            String?,
                threadInvitees:         [Invitee],
                threadMetadata:         String?,
                threadTitle:            String,
                threadType:             String?,
                uniqueId:               String?,
                messageContent:         String,
                messageMetaDataId:      Int?,
                messageMetaDataType:    String?,
                messageMetaDataOwner:   String?) {


        self.threadDescription  = threadDescription
        self.threadImage        = threadImage
        self.threadInvitees     = threadInvitees
        self.threadMetadata     = threadMetadata
        self.threadTitle        = threadTitle
        self.threadType         = threadType
        self.uniqueId           = uniqueId
        self.messageContent         = messageContent
        self.messageMetaDataId      = messageMetaDataId
        self.messageMetaDataType    = messageMetaDataType
        self.messageMetaDataOwner   = messageMetaDataOwner
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

