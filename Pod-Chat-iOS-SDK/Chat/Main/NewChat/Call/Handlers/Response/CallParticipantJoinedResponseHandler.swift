//
//  CallParticipantJoinedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK


fileprivate let CALL_PARTICIPANT_JOINED_NAME        = "CALL_PARTICIPANT_JOINED_NAME"
public var CALL_PARTICIPANT_JOINED_NAME_OBJECT = Notification.Name.init(CALL_PARTICIPANT_JOINED_NAME)

class CallParticipantJoinedResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callPartitipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else{return}
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){
            callback(.init(uniqueId:chatMessage.uniqueId , result: callPartitipants))
            chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_PARTICIPANT_JOINED)
        }
        NotificationCenter.default.post(name: CALL_PARTICIPANT_JOINED_NAME_OBJECT ,object: callPartitipants)
    }
}
