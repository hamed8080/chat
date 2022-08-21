//
//  IsPublicThreadNameAvailableResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class IsPublicThreadNameAvailableResponseHandler: ResponseHandler {

	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let thread = try? JSONDecoder().decode(PublicThreadNameAvailableResponse.self, from: data) else{return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: thread))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .IS_NAME_AVAILABLE)
	}
	
}
