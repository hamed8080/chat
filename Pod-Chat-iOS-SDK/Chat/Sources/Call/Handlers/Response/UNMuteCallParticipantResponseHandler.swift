//
//  UNMuteCallParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let UNMUTE_CALL_NAME        = "UNMUTE_CALL_NAME"
public var UNMUTE_CALL_NAME_OBJECT = Notification.Name.init(UNMUTE_CALL_NAME)

class UNMuteCallParticipantResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.callbacksManager.unMuteCallParticipantsDelegate?(callParticipants,chatMessage.uniqueId)
        NotificationCenter.default.post(name: UNMUTE_CALL_NAME_OBJECT ,object: callParticipants)

    }
}
