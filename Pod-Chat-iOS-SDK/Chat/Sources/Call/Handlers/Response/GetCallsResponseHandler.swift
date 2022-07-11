//
//  GetCallsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class GetCallsResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let calls = try? JSONDecoder().decode([Call].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: calls,contentCount: chatMessage.contentCount ?? 0))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_CALLS)
    }
}
