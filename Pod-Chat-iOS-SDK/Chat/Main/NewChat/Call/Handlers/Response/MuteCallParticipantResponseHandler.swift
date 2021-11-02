//
//  MuteCallParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let MUTE_CALL_NAME        = "MUTE_CALL_NAME"
public var MUTE_CALL_NAME_OBJECT = Notification.Name.init(MUTE_CALL_NAME)

class MuteCallParticipantResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.callbacksManager.muteCallParticipantsDelegate?(callParticipants,chatMessage.uniqueId)
        NotificationCenter.default.post(name: MUTE_CALL_NAME_OBJECT ,object: callParticipants)
    }
}
