//
//  StartCallRequestResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class StartCallRequestResponseHandler {
    
    ///Only call on receivers side. The starter of call never get this event.
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else{return}

        chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_RECEIVED(createCall))))
        chat.callState = .Requested
        startTimerTimeout(callId: createCall.callId)
        
        //SEND type 73 . This mean client receive call and showing ringing mode on call creator.        
        chat.callReceived(.init(callId: createCall.callId))
        
        chat.callbacksManager.callRequestArriveDelegate?(createCall,chatMessage.uniqueId)
    }
    
    ///maybe starter of call after start call request disconnected we need to close ui on the receiver side
    class func startTimerTimeout(callId:Int){
        let chat = Chat.sharedInstance
        Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
            if chat.callState == .Requested{
                if chat.config?.isDebuggingLogEnabled == true{
                    Chat.sharedInstance.logger?.log(title: "cancel call after \(chat.config?.callTimeout ?? 0) second")
                }
                chat.delegate?.chatEvent(event: .Call(CallEventModel(type: .CALL_ENDED(callId))))
                chat.callState = .Ended
            }
            timer.invalidate()
        }
    }
}
