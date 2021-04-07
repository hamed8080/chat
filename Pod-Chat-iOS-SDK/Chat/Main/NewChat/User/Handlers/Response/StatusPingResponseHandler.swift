//
//  StatusPingResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
class StatusPingResponseHandler: ResponseHandler{
	
	static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		guard let _ = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let _ = chatMessage.content?.data(using: .utf8) else {return}
		//no need to call callback
	}
}
