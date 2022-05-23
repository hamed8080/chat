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
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let conversations = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        let unreadCount = try? JSONDecoder().decode(UnreadCount.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId: chatMessage.subjectId)))
        if let unreadCount = unreadCount, let threadId = chatMessage.subjectId {
            chat.delegate?.chatEvent(event: .Thread(.THREAD_UNREAD_COUNT_UPDATED(threadId:threadId, count:unreadCount.unreadCount)))
            CacheFactory.write(cacheType: .SET_THREAD_UNREAD_COUNT(threadId, unreadCount.unreadCount))
        }
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: conversations))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LAST_SEEN_UPDATED)
    }
}

struct UnreadCount:Decodable{
    let unreadCount:Int
}
