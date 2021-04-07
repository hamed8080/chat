//
//  UnBlockResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
class UnBlockResponseHandler : ResponseHandler{
	
	
	static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let blockedResult = try? JSONDecoder().decode(BlockedUser.self, from: data) else{return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: blockedResult))
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
	
	
}
