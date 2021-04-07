//
//  SeenMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class SeenMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        if let callback =  Chat.sharedInstance.callbacksManager.getSeenCallback(chatMessage.uniqueId) {
            let message = Message(threadId: chatMessage.subjectId, pushMessageVO: chatMessage.content?.convertToJSON() ?? [:])
            chat.delegate?.messageEvents(model: .init(type: .MESSAGE_SEEN, chatMessage: chatMessage))
            let messageResponse = SeenMessageResponse(isSeen: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
            callback?(messageResponse , chatMessage.uniqueId, nil)
            chat.callbacksManager.removeSeenCallback(uniqueId: chatMessage.uniqueId)
        }
    }
    
}
