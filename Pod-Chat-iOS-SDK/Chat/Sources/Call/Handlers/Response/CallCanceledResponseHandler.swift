//
//  CallCanceledResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallCanceledResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_CANCELED(call))))
        chat.callbacksManager.callRejectedDelegate?(call,chatMessage.uniqueId)
    }
}
