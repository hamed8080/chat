//
//  MessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/8/21.
//

import Foundation
class MessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
		let chat = Chat.sharedInstance
        if chat.config?.enableCache == true, let data = chatMessage.content?.data(using: .utf8) , let message = try? JSONDecoder().decode(Message.self, from: data){
            CacheFactory.write(cacheType: .MESSAGE(message))
            
            if let messageId = message.id, let _ = message.participant?.id{ //check message has participant id and not a system broadcast message
                chat.deliver(.init(messageId: messageId))
            }
            if let threadId = message.threadId{
                CacheFactory.write(cacheType: .ADD_THREAD_UNREAD_COUNT(threadId))
            }
        }
        
        chat.delegate?.messageEvents(model: .init(type: .MESSAGE_NEW, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: .init(type:.THREAD_UNREAD_COUNT_UPDATED, chatMessage: chatMessage))
        CacheFactory.save()
    }
}
