//
//  StartCallRequestResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let RECEIVE_CALL_NAME        = "RECEIVE_CALL_NAME"
public var RECEIVE_CALL_NAME_OBJECT = Notification.Name.init(RECEIVE_CALL_NAME)

class StartCallRequestResponseHandler {
    
    ///Only call on receivers side. The starter of call never get this event.
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else{return}
        
        //SEND type 73 . This mean client receive call and showing ringing mode on call creator.        
        chat.callReceived(.init(callId: createCall.callId))
        
        chat.callbacksManager.callRequestArriveDelegate?(createCall,chatMessage.uniqueId)
		NotificationCenter.default.post(name: RECEIVE_CALL_NAME_OBJECT ,object: createCall)
        chat.callState = .Requested
        startTimerTimeout()
    }
    
    ///maybe starter of call after start call request disconnected we need to close ui on the receiver side
    class func startTimerTimeout(){
        let chat = Chat.sharedInstance
        Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
            if chat.callState == .Requested{
                if chat.config?.isDebuggingLogEnabled == true{
                    Chat.sharedInstance.logger?.log(title: "cancel call after \(chat.config?.callTimeout ?? 0) second")
                }
                
                NotificationCenter.default.post(name: END_CALL_NAME_OBJECT ,object: 0)
                chat.callState = .Ended
            }
            timer.invalidate()
        }
    }
}
