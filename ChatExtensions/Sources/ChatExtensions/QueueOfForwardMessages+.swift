//
//  File.swift
//  
//
//  Created by hamed on 4/16/23.
//

import ChatModels
import ChatDTO

public extension QueueOfForwardMessages {
    convenience init(forward: ForwardMessageRequest) {
        self.init(fromThreadId: forward.fromThreadId,
                  messageIds: forward.messageIds,
                  threadId: forward.threadId,
                  typeCode: forward.typeCode,
                  uniqueIds: forward.uniqueIds)
    }

    var request: ForwardMessageRequest {
        ForwardMessageRequest(fromThreadId: fromThreadId ?? -1,
                              threadId: threadId ?? -1,
                              messageIds: messageIds ?? [],
                              uniqueIds: uniqueIds ?? [])
    }
}
