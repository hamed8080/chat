//
//  SetProfileResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
class SetProfileResponseHandler: ResponseHandler{
	
	static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let profile = try? JSONDecoder().decode(Profile.self, from: data) else {return}
		callback(.init(uniqueId:chatMessage.uniqueId , result: profile))
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
}
