//
//  UserRemovedFromThreadServerAction.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/28/21.
//

import Foundation
import FanapPodAsyncSDK

class UserRemovedFromThreadServerAction: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        guard let threadId = chatMessage.subjectId else {return}
        chat.delegate?.chatEvent(event: .Thread(.THREAD_REMOVED_FROM(threadId: threadId)))
        
        if chat.config?.enableCache == true{
            CacheFactory.write(cacheType: .DELETE_THREADS([threadId]))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVED_FROM_THREAD)
    }
}
