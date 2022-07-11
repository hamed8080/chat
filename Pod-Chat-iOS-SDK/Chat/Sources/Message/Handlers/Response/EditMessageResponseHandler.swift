//
//  EditMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
import FanapPodAsyncSDK

class EditMessageResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        let message = Message(chatMessage: chatMessage)
        
        chat.delegate?.chatEvent(event: .Message(.MESSAGE_EDIT(message)))
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time:chatMessage.time, threadId: chatMessage.subjectId)))
        
        CacheFactory.write(cacheType: .DELETE_EDIT_MESSAGE_QUEUE(message))
        CacheFactory.write(cacheType: .MESSAGE(message))
        PSM.shared.save()
        
        guard let callback =  Chat.sharedInstance.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result:message))        
        chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
