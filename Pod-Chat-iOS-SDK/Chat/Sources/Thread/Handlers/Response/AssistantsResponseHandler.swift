//
//  AssistantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class AssistantsResponseHandler : ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: assistants))
        CacheFactory.write(cacheType: .INSERT_OR_UPDATE_ASSISTANTS(assistants))
        CacheFactory.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_ASSISTANTS)
    }
    
}
