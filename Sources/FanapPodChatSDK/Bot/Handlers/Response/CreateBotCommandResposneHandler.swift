//
//  CreateBotCommandResposneHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class CreateBotCommandResposneHandler: ResponseHandler{
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let botInfo = try? JSONDecoder().decode(BotInfo.self, from: data) else{return}
        
        chat.delegate?.chatEvent(event: .Bot(.CREATE_BOT_COMMAND(botInfo)))
        
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: botInfo))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DEFINE_BOT_COMMAND)
	}
}
