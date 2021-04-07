//
//  EditMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class EditMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        guard let callback =  Chat.sharedInstance.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        
        chat.delegate?.messageEvents(model: .init(type: .MESSAGE_EDIT, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
        let message = Message(threadId: chatMessage.subjectId, pushMessageVO: chatMessage.content?.convertToJSON() ?? [:])
        callback(.init(uniqueId: chatMessage.uniqueId ,result:message))
        CacheFactory.write(cacheType: .DELETE_EDIT_MESSAGE_QUEUE(message))
        CacheFactory.write(cacheType: .MESSAGE(message))
        PSM.shared.save()
        chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
