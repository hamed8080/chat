//
//  SeenMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
import FanapPodAsyncSDK

class SeenMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
		
		let chat = Chat.sharedInstance
        if let callback =  Chat.sharedInstance.callbacksManager.getSeenCallback(chatMessage.uniqueId) {
            let message = Message(chatMessage: chatMessage)
            chat.delegate?.chatEvent(event: .Message(.init(type: .MESSAGE_SEEN, chatMessage: chatMessage)))
            let messageResponse = SeenMessageResponse(isSeen: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
            callback?(messageResponse , chatMessage.uniqueId, nil)
            chat.callbacksManager.removeSeenCallback(uniqueId: chatMessage.uniqueId)
        }
    }
    
}
