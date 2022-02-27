//
//  StopBotResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class StopBotResponseHandler: ResponseHandler{
	
	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let botName = chatMessage.content else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: botName))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .STOP_BOT)
	}
}
