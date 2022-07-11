//
//  DeleteMessageResposneHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
import FanapPodAsyncSDK

class DeleteMessageResposneHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let deleteMessage = try? JSONDecoder().decode(Message.self, from: data) else {return}
        
        chat.delegate?.chatEvent(event: .Message(.MESSAGE_DELETE(deleteMessage)))
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId: chatMessage.subjectId)))
        guard let threadId = chatMessage.subjectId else {return}
        
        CacheFactory.write(cacheType: .DELETE_MESSAGE(threadId, messageId: deleteMessage.id ?? 0))
        CacheFactory.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: deleteMessage))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DELETE_MESSAGE)
    }
}

