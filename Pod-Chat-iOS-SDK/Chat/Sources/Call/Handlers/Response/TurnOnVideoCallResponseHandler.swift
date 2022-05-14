//
//  TurnOnVideoCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let TURN_ON_VIDEO_CALL_NAME        = "TURN_ON_VIDEO_CALL_NAME"
public var TURN_ON_VIDEO_CALL_NAME_OBJECT = Notification.Name.init(TURN_ON_VIDEO_CALL_NAME)

class TurnOnVideoCallResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        chat.callbacksManager.trunOnVideoCallParticipantsDelegate?(callParticipants , chatMessage.uniqueId)
        NotificationCenter.default.post(name: TURN_ON_VIDEO_CALL_NAME_OBJECT ,object: callParticipants)
    }
}
