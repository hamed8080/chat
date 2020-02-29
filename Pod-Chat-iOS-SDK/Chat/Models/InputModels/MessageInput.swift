//
//  MessageInput.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class MessageInput {
    
    public let forwardedMessageIds: [String]?
    public var forwardedUniqueIds:  [String]?
    public let repliedTo:           Int?
    public let text:                String?
    public let messageType:         MESSAGE_TYPE
    var metadata:                   String?
    public let systemMetadata:      String?
    public let uniqueId:            String
    
    public init(forwardedMessageIds:    [String]?,
                repliedTo:              Int?,
                text:                   String?,
                messageType:            MESSAGE_TYPE,
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
         messageType:           MESSAGE_TYPE,
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
            content["text"] = JSON(text_)
        }
        if let metadata_ = self.metadata {
            content["metadata"] = JSON(metadata_)
        }
        if let systemMetadata_ = self.systemMetadata {
            content["systemMetadata"] = JSON(systemMetadata_)
        }
        content["messageType"] = JSON(messageType.returnIntValue())
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
}
