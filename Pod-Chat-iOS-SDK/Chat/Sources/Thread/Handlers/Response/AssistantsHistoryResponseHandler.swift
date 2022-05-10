//
//  AssistantsHistoryResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class AssistantsHistoryResponseHandler : ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let assistantsActions = try? JSONDecoder().decode([AssistantAction].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: assistantsActions))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_ASSISTANT_HISTORY)
    }
}
