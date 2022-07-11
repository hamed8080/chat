//
//  CallClientErrorResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallClientErrorResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callClientError = try? JSONDecoder().decode(CallError.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_CLIENT_ERROR(callClientError))))
        
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: callClientError))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_CLIENT_ERRORS)
                
    }
}
