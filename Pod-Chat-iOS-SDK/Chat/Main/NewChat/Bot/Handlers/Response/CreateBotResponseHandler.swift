//
//  CreateBotResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class CreateBotResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		let chat = Chat.sharedInstance
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let bot = try? JSONDecoder().decode(Bot.self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: bot))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CREATE_BOT)
	}
}
