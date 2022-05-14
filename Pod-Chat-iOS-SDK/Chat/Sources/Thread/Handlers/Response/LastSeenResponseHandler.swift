//
//  LastSeenResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/28/21.
//

import Foundation
import FanapPodAsyncSDK

class LastSeenResponseHandler : ResponseHandler{


    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let conversations = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: conversations))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_UNREAD_COUNT_UPDATED, chatMessage: chatMessage)))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage)))    
        if let count = ThreadEventModel(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage).unreadCount,
           let threadId = chatMessage.subjectId {
            CacheFactory.write(cacheType: .SET_THREAD_UNREAD_COUNT(threadId, count))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LAST_SEEN_UPDATED)
    }
}
