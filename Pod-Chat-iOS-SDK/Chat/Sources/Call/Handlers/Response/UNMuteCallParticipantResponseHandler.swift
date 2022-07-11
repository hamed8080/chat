//
//  UNMuteCallParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class UNMuteCallParticipantResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_PARTICIPANT_UNMUTE(callParticipants))))
        chat.callbacksManager.unMuteCallParticipantsDelegate?(callParticipants, chatMessage.uniqueId)
    }
}
