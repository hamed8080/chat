//
//  StopBotResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class StopBotResponseHandler: ResponseHandler{
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
		
		guard let botName = chatMessage.content else {return}
        chat.delegate?.chatEvent(event: .Bot(.STOP_BOT(botName)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: botName))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .STOP_BOT)
	}
}