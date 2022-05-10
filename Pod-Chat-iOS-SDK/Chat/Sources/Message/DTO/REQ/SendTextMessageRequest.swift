//
//  SendTextMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
public class SendTextMessageRequest : BaseRequest {
    
    public let messageType:     MessageType
    public var metadata:        String?
    public let repliedTo:       Int?
    public let systemMetadata:  String?
    public let textMessage:     String
    public var threadId:        Int
    
    public init(threadId       : Int,
                textMessage    : String,
                messageType    : MessageType,
                metadata       : String?        = nil,
                repliedTo      : Int?           = nil,
                systemMetadata : String?        = nil,
                typeCode       : String?        = nil,
                uniqueId       : String?        = nil
    ) {
        self.messageType    = messageType
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage    = textMessage
        self.threadId       = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    
}
