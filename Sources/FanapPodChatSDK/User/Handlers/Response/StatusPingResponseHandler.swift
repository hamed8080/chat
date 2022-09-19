//
//  StatusPingResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class StatusPingResponseHandler: ResponseHandler{
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let _ = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let _ = chatMessage.content?.data(using: .utf8) else {return}
		//no need to call callback
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .STATUS_PING)
	}
}
