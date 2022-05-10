//
//  UserRemovedFromThreadServerAction.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/28/21.
//

import Foundation
import FanapPodAsyncSDK

class UserRemovedFromThreadServerAction: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_REMOVED_FROM, chatMessage: chatMessage)))
        
        if chat.config?.enableCache == true , let threadId = chatMessage.subjectId {
            CacheFactory.write(cacheType: .DELETE_THREADS([threadId]))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVED_FROM_THREAD)
    }
}
