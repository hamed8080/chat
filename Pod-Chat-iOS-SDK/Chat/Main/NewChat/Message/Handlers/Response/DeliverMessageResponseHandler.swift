//
//  DeliverMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class DeliverMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        if let callback =  Chat.sharedInstance.callbacksManager.getDeliverCallback(chatMessage.uniqueId) {
            let message = Message(threadId: chatMessage.subjectId, pushMessageVO: chatMessage.content?.convertToJSON() ?? [:])
            chat.delegate?.messageEvents(model: .init(type: .MESSAGE_DELIVERY, chatMessage: chatMessage))
            let messageResponse = DeliverMessageResponse(isDeliver: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
            callback?(messageResponse, chatMessage.uniqueId , nil)
            chat.callbacksManager.removeDeliverCallback(uniqueId: chatMessage.uniqueId)
        }
    }
}
