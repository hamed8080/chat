//
//  EditMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
import FanapPodAsyncSDK

class EditMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        
        chat.delegate?.chatEvent(event: .Message(.init(type: .MESSAGE_EDIT, chatMessage: chatMessage)))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage)))
        let message = Message(chatMessage: chatMessage)
        CacheFactory.write(cacheType: .DELETE_EDIT_MESSAGE_QUEUE(message))
        CacheFactory.write(cacheType: .MESSAGE(message))
        PSM.shared.save()
        
        guard let callback =  Chat.sharedInstance.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result:message))        
        chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
