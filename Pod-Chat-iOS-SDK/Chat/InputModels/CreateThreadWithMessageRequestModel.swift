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
    
    public let requestTypeCode:             String?
    public let requestUniqueId:             String
    
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
                requestTypeCode:        String?,
                requestUniqueId:        String?) {
        
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
        
        self.requestTypeCode            = requestTypeCode
        self.requestUniqueId            = requestUniqueId ?? NSUUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        
        var messageContentParams: JSON = [:]
        messageContentParams["text"] = JSON(self.messageText)
        if let type = self.messageType {
            messageContentParams["type"] = JSON(type)
        }
        if let metaData = self.messageMetaData {
            messageContentParams["metaData"] = JSON(metaData)
        }
        if let systemMetadata = self.messageSystemMetaData {
            messageContentParams["systemMetadata"] = JSON(systemMetadata)
        }
        if let repliedTo = self.messageRepliedTo {
            messageContentParams["repliedTo"] = JSON(repliedTo)
        }
        if let forwardedMessageIds = self.messageForwardedMessageIds {
            messageContentParams["forwardedMessageIds"] = JSON(forwardedMessageIds)
        }
        if let forwardedUniqueIds = self.messageForwardedUniqueIds {
            messageContentParams["forwardedUniqueIds"] = JSON(forwardedUniqueIds)
        }
        messageContentParams["uniqueId"] = JSON(self.requestUniqueId)
        
        var myContent: JSON = [:]
        myContent["message"]    = JSON(messageContentParams)
        myContent["uniqueId"]   = JSON(self.requestUniqueId)
        myContent["title"]      = JSON(self.threadTitle)
        var inviteees = [JSON]()
        for item in self.threadInvitees {
            inviteees.append(item.formatToJSON())
        }
        myContent["invitees"] = JSON(inviteees)
        if let image = self.threadImage {
            myContent["image"] = JSON(image)
        }
        if let metaData = self.threadMetadata {
            myContent["metadata"] = JSON(metaData)
        }
        if let description = self.threadDescription {
            myContent["description"] = JSON(description)
        }
        let type = self.threadType
        var theType: Int = 0
        switch type {
        case ThreadTypes.NORMAL:        theType = 0
        case ThreadTypes.OWNER_GROUP:   theType = 1
        case ThreadTypes.PUBLIC_GROUP:  theType = 2
        case ThreadTypes.CHANNEL_GROUP: theType = 4
        case ThreadTypes.CHANNEL:       theType = 8
        default: break
        }
        myContent["type"] = JSON(theType)
        
        return myContent
    }
    
}


