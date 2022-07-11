//
//  CallsToJoinResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallsToJoinResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let callsToJoin = try? JSONDecoder().decode([Call].self, from: data) else{return}
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: callsToJoin))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_CALLS_TO_JOIN)
    }
}
