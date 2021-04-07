//
//  NewReplyMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
public class NewReplyMessageRequest : NewSendTextMessageRequest {
    
    public init(threadId       : Int,
                repliedTo      : Int,
                textMessage    : String,
                messageType    : MessageType,
                metadata       : String?        = nil,
                systemMetadata : String?        = nil,
                typeCode       : String?        = nil,
                uniqueId       : String?        = nil
    ) {

        super.init(threadId: threadId,
                   textMessage: textMessage,
                   messageType: messageType,
                   metadata: metadata,
                   repliedTo: repliedTo,
                   systemMetadata: systemMetadata,
                   typeCode: typeCode,
                   uniqueId: uniqueId)
    }
    
}
