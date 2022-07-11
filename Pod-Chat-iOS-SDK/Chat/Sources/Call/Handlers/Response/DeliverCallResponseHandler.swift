//
//  DeliverCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class DeliverCallResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_DELIVERED(call))))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: call))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DELIVERED_CALL_REQUEST)
    }
}
