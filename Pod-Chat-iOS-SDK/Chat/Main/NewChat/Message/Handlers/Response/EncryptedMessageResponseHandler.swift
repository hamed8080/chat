//
//  EncryptedMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by hamed on 4/24/22.
//

import Foundation
import FanapPodAsyncSDK

class EncryptedMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
//        let chat = Chat.sharedInstance
//        if chat.config?.enableCache == true, let data = chatMessage.content?.data(using: .utf8) , let message = try? JSONDecoder().decode(Message.self, from: data){
//            if message.threadId == nil{
//                message.threadId = chatMessage.subjectId ?? message.conversation?.id
//            }
//            CacheFactory.write(cacheType: .MESSAGE(message))
//
//            if let messageId = message.id, let _ = message.participant?.id{ //check message has participant id and not a system broadcast message
//                chat.deliver(.init(messageId: messageId))
//            }
//            if let threadId = message.threadId{
//                CacheFactory.write(cacheType: .SET_THREAD_UNREAD_COUNT(threadId, message.conversation?.unreadCount ?? 0))
//            }
//        }
//
//        chat.delegate?.messageEvents(model: .init(type: .MESSAGE_NEW, chatMessage: chatMessage))
//        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
//        chat.delegate?.threadEvents(model: .init(type:.THREAD_UNREAD_COUNT_UPDATED, chatMessage: chatMessage))
//        CacheFactory.save()
    }
    
    
    static func isEncryptedMessage(_ chatMessage:NewChatMessage)->Bool{
        if let data = chatMessage.content?.data(using: .utf8),
           let message = try? JSONDecoder().decode(Message.self, from: data),
           message.messageType == MessageType.ENCRPTED_TEXT.rawValue
        {
            return true
        }else{
            return false
        }
    }
    
    static func tryToDecrypt(_ chatMessage:NewChatMessage){
        if let data = chatMessage.content?.data(using: .utf8),
           let message = try? JSONDecoder().decode(Message.self, from: data),
           message.messageType == MessageType.ENCRPTED_TEXT.rawValue
        {
            let encryption = Encryption()
            encryption.startDecryption(message)
        }
    }
    
}
