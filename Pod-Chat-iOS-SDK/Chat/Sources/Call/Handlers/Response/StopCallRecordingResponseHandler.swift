//
//  StopCallRecordingResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let STOP_CALL_RECORDING_NAME        = "STOP_CALL_RECORDING_NAME"
public var STOP_CALL_RECORDING_NAME_OBJECT = Notification.Name.init(STOP_CALL_RECORDING_NAME)

class StopCallRecordingResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let participant = try? JSONDecoder().decode(Participant.self, from: data) else{return}
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){
            callback(.init(uniqueId:chatMessage.uniqueId , result: participant))
            chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .STOP_RECORDING)
        }
        NotificationCenter.default.post(name: STOP_CALL_RECORDING_NAME_OBJECT ,object: participant)

    }
}
