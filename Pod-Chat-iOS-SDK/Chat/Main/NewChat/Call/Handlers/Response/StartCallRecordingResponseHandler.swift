//
//  StartCallRecordingResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let START_CALL_RECORDING_NAME        = "START_CALL_RECORDING_NAME"
public var START_CALL_RECORDING_NAME_OBJECT = Notification.Name.init(START_CALL_RECORDING_NAME)

class StartCallRecordingResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let participant = try? JSONDecoder().decode(Participant.self, from: data) else{return}
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){
            callback(.init(uniqueId:chatMessage.uniqueId , result: participant))
            chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .START_RECORDING)
        }
        NotificationCenter.default.post(name: START_CALL_RECORDING_NAME_OBJECT ,object: participant)
    }
}
