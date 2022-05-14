//
//  CallParticipantLeftResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let CALL_PARTICIPANT_LEFT_NAME        = "CALL_PARTICIPANT_LEFT_NAME"
public var CALL_PARTICIPANT_LEFT_NAME_OBJECT = Notification.Name.init(CALL_PARTICIPANT_LEFT_NAME)

class CallParticipantLeftResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){            
            callback(.init(uniqueId:chatMessage.uniqueId , result: callParticipants))
            chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LEAVE_CALL)
        }
        NotificationCenter.default.post(name: CALL_PARTICIPANT_LEFT_NAME_OBJECT ,object: callParticipants)
    }
}
