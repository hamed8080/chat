//
//  File.swift
//  
//
//  Created by hamed on 4/16/23.
//

import ChatModels
import ChatDTO

public extension QueueOfEditMessages {
   convenience init(edit: EditMessageRequest) {
       self.init(messageId: edit.messageId,
                 messageType: edit.messageType,
                 metadata: edit.metadata,
                 repliedTo: edit.repliedTo,
                 textMessage: edit.textMessage,
                 threadId: edit.threadId,
                 typeCode: edit.typeCode,
                 uniqueId: edit.uniqueId)
    }

    var request: EditMessageRequest {
        EditMessageRequest(threadId: threadId ?? -1,
                           messageType: messageType ?? .unknown,
                           messageId: messageId ?? -1,
                           textMessage: textMessage ?? "",
                           repliedTo: repliedTo,
                           metadata: metadata,
                           uniqueId: uniqueId)
    }
}
