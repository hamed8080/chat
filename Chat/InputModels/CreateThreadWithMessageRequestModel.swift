//
//  CreateThreadWithMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CreateThreadWithMessageRequestModel {
    
    public let threadTitle:         String
    public let threadType:          String?
    public let threadInvitees:      [Invitee]
    public let uniqueId:            String?
    public let messageContent:          String
    public let messageMetaDataId:       Int?
    public let messageMetaDataType:     String?
    public let messageMetaDataOwner:    String?
    
    
    public init(threadTitle:           String,
                threadType:            String?,
                threadInvitees:        [Invitee],
                uniqueId:              String?,
                messageContent:        String,
                messageMetaDataId:     Int?,
                messageMetaDataType:   String?,
                messageMetaDataOwner:  String?) {
        
        self.uniqueId       = uniqueId
        
        self.threadTitle    = threadTitle
        self.threadType     = threadType
        self.threadInvitees = threadInvitees
        self.messageContent         = messageContent
        self.messageMetaDataId      = messageMetaDataId
        self.messageMetaDataType    = messageMetaDataType
        self.messageMetaDataOwner   = messageMetaDataOwner
    }
    
}

