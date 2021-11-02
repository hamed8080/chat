//
//  EndCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let END_CALL_NAME        = "END_CALL_NAME"
public var END_CALL_NAME_OBJECT = Notification.Name.init(END_CALL_NAME)

class EndCallResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let callId = chatMessage.subjectId else{return}
        chat.callbacksManager.callEndDelegate?(callId,chatMessage.uniqueId)
        NotificationCenter.default.post(name: END_CALL_NAME_OBJECT ,object: callId)
    }
}
