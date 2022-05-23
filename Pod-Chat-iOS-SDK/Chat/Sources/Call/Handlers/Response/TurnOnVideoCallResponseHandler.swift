//
//  TurnOnVideoCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class TurnOnVideoCallResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .TURN_VIDDEO_ON(callParticipants))))
        chat.callbacksManager.trunOnVideoCallParticipantsDelegate?(callParticipants , chatMessage.uniqueId)
    }
}
