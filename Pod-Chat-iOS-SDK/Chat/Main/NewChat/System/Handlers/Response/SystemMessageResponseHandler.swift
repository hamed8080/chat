//
//  SystemMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/28/21.
//

import Foundation
import FanapPodAsyncSDK

class SystemMessageResponseHandler : ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        log.verbose("Message of type 'SYSTEM_MESSAGE' revieved", context: "Chat")
        chat.delegate?.systemEvents(model: .init(type: .IS_TYPING, time: chatMessage.time, threadId: chatMessage.subjectId, user: chatMessage.content))
    }
    
}
