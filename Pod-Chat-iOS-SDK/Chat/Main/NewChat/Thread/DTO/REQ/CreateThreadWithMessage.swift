//
//  CreateThreadWithMessage.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
public class CreateThreadWithMessage : NewCreateThreadRequest {
    
    public var message:CreateThreadMessage

    public init(description: String?,
                         image: String?,
                         invitees: [Invitee],
                         metadata: String?,
                         title: String,
                         type: ThreadTypes?,
                         uniqueName: String?,
                         message:CreateThreadMessage
                         ) {
        self.message = message
        super.init(description: description,
                   image: image,
                   invitees: invitees,
                   metadata: metadata,
                   title: title,
                   type: type,
                   uniqueName: uniqueName,
                   typeCode: nil,
                   uniqueId: nil)

    }
    
    private enum CodingKeys : String , CodingKey{
        case message = "message"
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
    }
}


public class CreateThreadMessage : Encodable{
    
    public let forwardedMessageIds : [String]?
    public var forwardedUniqueIds  : [String]?
    public let repliedTo           : Int?
    public let text                : String?
    public let messageType         : MessageType
    var metadata                   : String?
    public let systemMetadata      : String?
    
    public init(forwardedMessageIds:    [String]? = nil,
                repliedTo:              Int? = nil,
                text:                   String? = nil,
                messageType:            MessageType,
                systemMetadata:         String? = nil) {
        
        self.forwardedMessageIds = forwardedMessageIds
        self.repliedTo      = repliedTo
        self.text           = text
        self.messageType    = messageType
        self.metadata       = nil
        self.systemMetadata = systemMetadata
        
        forwardedMessageIds?.forEach({ messageId in
            self.forwardedUniqueIds?.append(UUID().uuidString)
        })
    }
    
    private enum CodingKeys : String , CodingKey{
        case forwardedMessageIds = "forwardedMessageIds"
        case forwardedUniqueIds  = "forwardedUniqueIds"
        case repliedTo           = "repliedTo"
        case text                = "text"
        case metadata            = "metadata"
        case systemMetadata      = "systemMetadata"
        case messageType         = "messageType"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(forwardedMessageIds, forKey: .forwardedMessageIds)
        try container.encodeIfPresent(forwardedUniqueIds, forKey: .forwardedUniqueIds)
        try container.encodeIfPresent(repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(messageType , forKey: .messageType)
    }

}
