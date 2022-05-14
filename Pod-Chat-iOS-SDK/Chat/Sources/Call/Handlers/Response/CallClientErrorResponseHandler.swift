//
//  CallClientErrorResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallClientErrorResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callClientError = try? JSONDecoder().decode(CallError.self, from: data) else{return}
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){
            callback(.init(uniqueId:chatMessage.uniqueId , result: callClientError))
            chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_CLIENT_ERRORS)
        }
        chat.delegate?.callError(error: callClientError)        
    }
}
