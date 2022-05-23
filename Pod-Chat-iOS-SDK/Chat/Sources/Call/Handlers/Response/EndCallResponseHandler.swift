//
//  EndCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class EndCallResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let callId = chatMessage.subjectId else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_ENDED(callId))))
        chat.callState = .Ended
        chat.callbacksManager.callEndDelegate?(callId,chatMessage.uniqueId)
    }
}
