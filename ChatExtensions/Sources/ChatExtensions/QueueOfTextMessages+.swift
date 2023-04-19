//
//  File.swift
//  
//
//  Created by hamed on 4/16/23.
//

import ChatDTO
import ChatModels

public extension QueueOfTextMessages {
   convenience init(textRequest: SendTextMessageRequest) {
       self.init(messageType: textRequest.messageType,
                 metadata: textRequest.metadata,
                 repliedTo: textRequest.repliedTo,
                 systemMetadata: textRequest.systemMetadata,
                 textMessage: textRequest.textMessage,
                 threadId: textRequest.threadId,
                 typeCode: textRequest.typeCode,
                 uniqueId: textRequest.uniqueId)
    }

    var request: SendTextMessageRequest {
        SendTextMessageRequest(threadId: threadId ?? -1,
                               textMessage: textMessage ?? "",
                               messageType: messageType ?? .unknown,
                               metadata: metadata,
                               repliedTo: repliedTo,
                               systemMetadata: systemMetadata,
                               uniqueId: uniqueId)
    }
}
