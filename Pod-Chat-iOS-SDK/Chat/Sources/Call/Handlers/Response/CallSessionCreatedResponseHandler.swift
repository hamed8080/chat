//
//  CallSessionCreatedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let CALL_SESSION_CREATED_NAME        = "CALL_SESSION_CREATED_NAME"
public var CALL_SESSION_CREATED_NAME_OBJECT = Notification.Name.init(CALL_SESSION_CREATED_NAME)

class CallSessionCreatedResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
		
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else{return}
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CALL_SESSION_CREATED)
		if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId){
			callback(.init(uniqueId:chatMessage.uniqueId , result: createCall))
		}
        chat.callState = .Created
		NotificationCenter.default.post(name: CALL_SESSION_CREATED_NAME_OBJECT ,object: createCall)
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
