//
//  DeleteMessageResposneHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
import FanapPodAsyncSDK

class DeleteMessageResposneHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.messageEvents(model: .init(type: .MESSAGE_DELETE, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: ThreadEventModel(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let threadId = chatMessage.subjectId else {return}
        guard let deleteMessage = try? JSONDecoder().decode(DeleteMessage.self, from: data) else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: deleteMessage))
        CacheFactory.write(cacheType: .DELETE_MESSAGE(threadId, messageId: deleteMessage.messageId)) // no need save context use exceute
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}

