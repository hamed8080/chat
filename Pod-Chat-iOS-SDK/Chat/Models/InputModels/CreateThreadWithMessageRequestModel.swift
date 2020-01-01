//
//  CreateThreadWithMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class CreateThreadWithMessageRequestModel {
    
    public var createThreadInput:   CreateThreadRequestModel
    public var sendMessageInput:    MessageInput?
    
//    public let description: String?
//    public let image:       String?
//    public let invitees:    [Invitee]
//    public let metadata:    String?
//    public let title:       String
//    public let type:        ThreadTypes?
//    public let message:     MessageInput
    
//    public let typeCode:    String?
//    public let uniqueId:    String?
    
    public init(createThreadInput:  CreateThreadRequestModel,
                sendMessageInput:   MessageInput?) {
//                description:    String?,
//                image:          String?,
//                invitees:       [Invitee],
//                metadata:       String?,
//                title:          String,
//                type:           ThreadTypes?,
//                message:        MessageInput?,
//                typeCode:       String?,
//                uniqueId:       String?) {
        
//        self.description    = description
//        self.image          = image
//        self.invitees       = invitees
//        self.metadata       = metadata
//        self.title          = title
//        self.type           = type
//        self.sendMessageInput        = message
//        self.typeCode       = typeCode
//        self.uniqueId       = uniqueId
        
        self.createThreadInput  = createThreadInput
        self.sendMessageInput   = sendMessageInput
        
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["title"] = JSON(self.createThreadInput.title)
        var inviteees = [JSON]()
        for item in self.createThreadInput.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let description = self.createThreadInput.description {
            content["description"] = JSON(description)
        }
        if let image = self.createThreadInput.image {
            content["image"] = JSON(image)
        }
        if let metadata2 = self.createThreadInput.metadata {
            content["metadata"] = JSON(metadata2)
        }
        content["type"] = JSON(self.createThreadInput.type?.intValue() ?? 0)
        
        if let message_ = sendMessageInput {
            content["message"] = message_.convertContentToJSON()
        }
        
        return content
    }
    
}


open class MessageInput {
    
    public let forwardedMessageIds: [String]?
    public var forwardedUniqueIds:  [String]?
    public let repliedTo:           Int?
    public let text:                String?
    public let type:                String?
    public var metadata:            JSON?
    public let systemMetadata:      JSON?
    public let uniqueId:            String?
    
    init(forwardedMessageIds:   [String]?,
         repliedTo:             Int?,
         text:                  String?,
         type:                  String?,
         metadata:              JSON?,
         systemMetadata:        JSON?,
         uniqueId:              String?) {
        
        self.forwardedMessageIds = forwardedMessageIds
        if (forwardedMessageIds?.count ?? 0) > 0 {
            self.forwardedUniqueIds = []
        }
        for _ in self.forwardedMessageIds ?? [] {
            self.forwardedUniqueIds?.append(UUID().uuidString)
        }
        self.repliedTo      = repliedTo
        self.text           = text
        self.type           = type
        self.metadata       = metadata
        self.systemMetadata = systemMetadata
        self.uniqueId       = uniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let forwardedMessageIds_ = self.forwardedMessageIds {
            content["forwardedMessageIds"] = JSON(forwardedMessageIds_)
        }
        if let forwardedUniqueIds_ = self.forwardedUniqueIds {
            content["forwardedUniqueIds"] = JSON(forwardedUniqueIds_)
        }
        if let repliedTo_ = self.repliedTo {
            content["repliedTo"] = JSON(repliedTo_)
        }
        if let text_ = self.text {
            content["text"] = JSON(text_)
        }
        if let type_ = self.type {
            content["type"] = JSON(type_)
        }
        if let metadata_ = self.metadata {
            content["metadata"] = JSON(metadata_)
        }
        if let systemMetadata_ = self.systemMetadata {
            content["systemMetadata"] = JSON(systemMetadata_)
        }
        if let uniqueId_ = self.uniqueId {
            content["uniqueId"] = JSON(uniqueId_)
        }
        
        return content
    }
    
}





//open class CreateThreadWithMessageRequestModel {
//
//    public let threadDescription:       String?
//    public let threadImage:             String?
//    public let threadInvitees:          [Invitee]
//    public let threadMetadata:          String?
//    public let threadTitle:             String
//    public let threadType:              ThreadTypes
//
//    public let messageForwardedMessageIds:  String?
//    public let messageForwardedUniqueIds:   String?
//    public let messageMetadata:             String?
//    public let messageRepliedTo:            Int?
//    public let messageSystemMetadata:       String?
//    public let messageText:                 String
//    public let messageType:                 String?
//
//    public let typeCode:                    String?
//    public let uniqueId:                    String
//
//    public init(threadDescription:      String?,
//                threadImage:            String?,
//                threadInvitees:         [Invitee],
//                threadMetadata:         String?,
//                threadTitle:            String,
//                threadType:             ThreadTypes,
//                messageForwardedMessageIds: String?,
//                messageForwardedUniqueIds:  String?,
//                messageMetadata:        String?,
//                messageRepliedTo:       Int?,
//                messageSystemMetadata:  String?,
//                messageText:            String,
//                messageType:            String?,
//                typeCode:               String?,
//                uniqueId:               String?) {
//
//        self.threadDescription  = threadDescription
//        self.threadImage        = threadImage
//        self.threadInvitees     = threadInvitees
//        self.threadMetadata     = threadMetadata
//        self.threadTitle        = threadTitle
//        self.threadType         = threadType
//
//        self.messageForwardedMessageIds = messageForwardedMessageIds
//        self.messageForwardedUniqueIds  = messageForwardedUniqueIds
//        self.messageMetadata            = messageMetadata
//        self.messageRepliedTo           = messageRepliedTo
//        self.messageSystemMetadata      = messageSystemMetadata
//        self.messageText                = messageText
//        self.messageType                = messageType
//
//        self.typeCode                   = typeCode
//        self.uniqueId                   = uniqueId ?? NSUUID().uuidString
//    }
//
//    func convertContentToJSON() -> JSON {
//
//        var messageContentParams: JSON = [:]
//        messageContentParams["text"] = JSON(self.messageText)
//        if let type = self.messageType {
//            messageContentParams["type"] = JSON(type)
//        }
//        if let metadata = self.messageMetadata {
//            messageContentParams["metadata"] = JSON(metadata)
//        }
//        if let systemMetadata = self.messageSystemMetadata {
//            messageContentParams["systemMetadata"] = JSON(systemMetadata)
//        }
//        if let repliedTo = self.messageRepliedTo {
//            messageContentParams["repliedTo"] = JSON(repliedTo)
//        }
//        if let forwardedMessageIds = self.messageForwardedMessageIds {
//            messageContentParams["forwardedMessageIds"] = JSON(forwardedMessageIds)
//        }
//        if let forwardedUniqueIds = self.messageForwardedUniqueIds {
//            messageContentParams["forwardedUniqueIds"] = JSON(forwardedUniqueIds)
//        }
//        messageContentParams["uniqueId"] = JSON(self.uniqueId)
//
//        var myContent: JSON = [:]
//        myContent["message"]    = JSON(messageContentParams)
//        myContent["uniqueId"]   = JSON(self.uniqueId)
//        myContent["title"]      = JSON(self.threadTitle)
//        var inviteees = [JSON]()
//        for item in self.threadInvitees {
//            inviteees.append(item.formatToJSON())
//        }
//        myContent["invitees"] = JSON(inviteees)
//        if let image = self.threadImage {
//            myContent["image"] = JSON(image)
//        }
//        if let metadata = self.threadMetadata {
//            myContent["metadata"] = JSON(metadata)
//        }
//        if let description = self.threadDescription {
//            myContent["description"] = JSON(description)
//        }
//        let type = self.threadType
//        var theType: Int = 0
//        switch type {
//        case ThreadTypes.NORMAL:        theType = 0
//        case ThreadTypes.OWNER_GROUP:   theType = 1
//        case ThreadTypes.PUBLIC_GROUP:  theType = 2
//        case ThreadTypes.CHANNEL_GROUP: theType = 4
//        case ThreadTypes.CHANNEL:       theType = 8
//        default: break
//        }
//        myContent["type"] = JSON(theType)
//
//        return myContent
//    }
//
//}


