//
//  UserBotsResposneHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class UserBotsResposneHandler: ResponseHandler{
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let userBots = try? JSONDecoder().decode([BotInfo].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: userBots))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_USER_BOTS)
	}
}
