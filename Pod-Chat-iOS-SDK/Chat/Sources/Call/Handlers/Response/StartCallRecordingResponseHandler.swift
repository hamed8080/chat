//
//  StartCallRecordingResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class StartCallRecordingResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let participant = try? JSONDecoder().decode(Participant.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .START_CALL_RECORDING(participant))))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: participant))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .START_RECORDING)
    }
}
