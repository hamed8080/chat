//
//  MessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/8/21.
//

import Foundation
import FanapPodAsyncSDK

class MessageResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) , let message = try? JSONDecoder().decode(Message.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Message(.MESSAGE_NEW(message)))
        
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId: chatMessage.subjectId)))
        let unreadCount = try? JSONDecoder().decode(UnreadCount.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        chat.delegate?.chatEvent(event: .Thread(.THREAD_UNREAD_COUNT_UPDATED(threadId: chatMessage.subjectId ?? 0, count: unreadCount?.unreadCount ?? 0)))
        CacheFactory.save()
        
        if chat.config?.enableCache == true{
            
            if message.threadId == nil{
                message.threadId = chatMessage.subjectId ?? message.conversation?.id
            }
            CacheFactory.write(cacheType: .MESSAGE(message))
            
            if let messageId = message.id, let _ = message.participant?.id{ //check message has participant id and not a system broadcast message
                chat.deliver(.init(messageId: messageId))
            }
            if let threadId = message.threadId{
                CacheFactory.write(cacheType: .SET_THREAD_UNREAD_COUNT(threadId, message.conversation?.unreadCount ?? 0))
            }
        }
    }
}
