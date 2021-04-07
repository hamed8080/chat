//
//  CreateThreadMessageInput.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class CreateThreadMessageInput: RequestModelDelegates {
    
    public let forwardedMessageIds: [String]?
    public var forwardedUniqueIds:  [String]?
    public let repliedTo:           Int?
    public let text:                String?
    public let messageType:         MessageType
    var metadata:                   String?
    public let systemMetadata:      String?
    public let uniqueId:            String
    
    public init(forwardedMessageIds:    [String]?,
                repliedTo:              Int?,
                text:                   String?,
                messageType:            MessageType,
//                metadata:              String?,
                systemMetadata:         String?,
                uniqueId:               String?) {
        
        self.forwardedMessageIds = forwardedMessageIds
        if (forwardedMessageIds?.count ?? 0) > 0 {
            self.forwardedUniqueIds = []
        }
        for _ in self.forwardedMessageIds ?? [] {
            self.forwardedUniqueIds?.append(UUID().uuidString)
        }
        self.repliedTo      = repliedTo
        self.text           = text
        self.messageType    = messageType
        self.metadata       = nil
        self.systemMetadata = systemMetadata
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    init(forwardedMessageIds:   [String]?,
         repliedTo:             Int?,
         text:                  String?,
         messageType:           MessageType,
         metadata:              String?,
         systemMetadata:        String?,
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
        self.messageType    = messageType
        self.metadata       = metadata
        self.systemMetadata = systemMetadata
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
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
            let theText = MakeCustomTextToSend(message: text_).replaceSpaceEnterWithSpecificCharecters()
            content["text"] = JSON(theText)
        }
        if let metadata_ = self.metadata {
            let theMeta = MakeCustomTextToSend(message: metadata_).replaceSpaceEnterWithSpecificCharecters()
            content["metadata"] = JSON(theMeta)
        }
        if let systemMetadata_ = self.systemMetadata {
            let theSystemMeta = MakeCustomTextToSend(message: systemMetadata_).replaceSpaceEnterWithSpecificCharecters()
            content["systemMetadata"] = JSON(theSystemMeta)
        }
        content["messageType"] = JSON(messageType.returnIntValue())
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class MessageInput: CreateThreadMessageInput {
    
}
