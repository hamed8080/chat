//
//  DeleteMessageResposneHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
import FanapPodAsyncSDK

class DeleteMessageResposneHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Message(.init(type: .MESSAGE_DELETE, chatMessage: chatMessage)))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage)))        
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let threadId = chatMessage.subjectId else {return}
        guard let deleteMessage = try? JSONDecoder().decode(DeleteMessage.self, from: data) else {return}
        CacheFactory.write(cacheType: .DELETE_MESSAGE(threadId, messageId: deleteMessage.messageId))
        CacheFactory.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: deleteMessage))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DELETE_MESSAGE)
    }
}

