//
//  CallParticipantJoinedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallParticipantJoinedResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callPartitipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_PARTICIPANT_JOINED(callPartitipants))))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: callPartitipants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_PARTICIPANT_JOINED)
    }
}
