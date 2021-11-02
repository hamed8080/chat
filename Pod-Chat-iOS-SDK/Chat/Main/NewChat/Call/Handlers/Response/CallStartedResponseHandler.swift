//
//  CallStartedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let STARTED_CALL_NAME        = "STARTED_CALL_NAME"
public var STARTED_CALL_NAME_OBJECT = Notification.Name.init(STARTED_CALL_NAME)

class CallStartedResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard var callStarted = try? JSONDecoder().decode(StartCall.self, from: data) else{return}
        callStarted.callId = chatMessage.subjectId
        chat.callbacksManager.callStartedDelegate?(callStarted,chatMessage.uniqueId)
        NotificationCenter.default.post(name: STARTED_CALL_NAME_OBJECT ,object: callStarted)
    }
}
