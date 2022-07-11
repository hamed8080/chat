//
//  CallSessionCreatedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallSessionCreatedResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
        let chat = Chat.sharedInstance
		
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Call(CallEventModel(type:.CALL_CREATE(createCall))))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: createCall))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_SESSION_CREATED)
        
        chat.callState = .Created
		startTimerTimeout(createCall)
    }
	
	///end call if no one doesn't accept or available to answer call
	class func startTimerTimeout(_ createCall:CreateCall){
		let chat = Chat.sharedInstance
		Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
			if chat.callState == .Created{
				if chat.config?.isDebuggingLogEnabled == true{
                    Chat.sharedInstance.logger?.log(title: "cancel call after \(chat.config?.callTimeout ?? 0) second waiting to accept by user")
				}
				let call = Call(id: createCall.callId,
								creatorId: 0,
								type: createCall.type,
								isGroup: false)
				let req = CancelCallRequest(call: call)
				chat.cancelCall(req) { uniqueId in
					
				}
			}
			timer.invalidate()
		}
	}
}
