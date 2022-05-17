//
//  MessageDeliveredUsersResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/27/21.
//

import Foundation
import FanapPodAsyncSDK

class MessageDeliveredUsersResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let history = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: history , contentCount: chatMessage.contentCount ?? 0 ))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_MESSAGE_DELEVERY_PARTICIPANTS)
	}
}

